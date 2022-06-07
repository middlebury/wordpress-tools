<?php
/**
 * @since 3/30/09
 * @package directory
 *
 * @copyright Copyright &copy; 2009, Middlebury College
 * @license http://www.gnu.org/copyleft/gpl.html GNU General Public License (GPL)
 */

/**
 *  An data-access object for reading LDAP results.
 *
 * @since 3/30/09
 * @package directory
 *
 * @copyright Copyright &copy; 2009, Middlebury College
 * @license http://www.gnu.org/copyleft/gpl.html GNU General Public License (GPL)
 */
class LdapGroup
	extends LdapUser
{

	/**
	 * Constructor
	 *
	 * @param LdapConnector $connector
	 * @param string $idAttribute
	 * @param array $attributeMap
	 * @param array $entryArray
	 * @return void
	 * @access public
	 * @since 3/30/09
	 */
	public function __construct (LdapConnector $connector, $idAttribute, array $attributeMap, array $entryArray) {
		parent::__construct($connector, $idAttribute, $attributeMap, $entryArray);

		$this->members = array();
		if (isset($this->entryArray['member'])) {
			$numValues = intval($this->entryArray['member']['count']);

			if ($numValues) {
				$this->members = array_unique($this->extractMemberDNs($this->entryArray['member']));
				sort($this->members);
				unset($this->entryArray['member']);
			}
			// Handle AD range values;
			else {
				$this->members = $this->fetchRangeMembers($this->entryArray);
				$this->members = array_unique($this->members);
				sort($this->members);
			}
		}
	}

	/**
	 * Answer an array of member DNs that are paginated in ranges.
	 *
	 * @param array $entryArray
	 * @return array of member DNs.
	 */
	private function fetchRangeMembers (array $entryArray) {
		$members = array();
		foreach (array_keys($entryArray) as $key) {
			if (preg_match('/^member;range=([0-9]+)-([0-9]+|\*)$/i', $key, $matches)) {
				$rangeMin = intval($matches[1]);
				if ($matches[2] == '*')
					$rangeMax = intval($entryArray[$key]['count'] + $rangeMin);
				else
					$rangeMax = intval($matches[2]);

				$max = $rangeMax - $rangeMin;
				$start = $rangeMax + 1;

				// Extract our range page.
				$members = $this->extractMemberDNs($entryArray[$key]);
				unset($entryArray);

				// If there are no more members, end our recursion.
				if (!count($members))
					return $members;

				// Combine with the next page recursively
				try {
					$attras = $this->connector->read($this->getId(), array("member;range=".$start."-*"));
					$members = array_merge($members, $this->fetchRangeMembers($attras));
				} catch (LDAPException $e) {
					// Ignore if we have no more results
				}
				break;
			}
		}
		return $members;
	}

	/**
	 * Extract member DNs from an attribute array.
	 *
	 * @param array $attributeArray
	 * @return array
	 */
	private function extractMemberDNs (array $attributeArray) {
		$numValues = intval($attributeArray['count']);
		$members = array();
		for ($i = 0; $i < $numValues; $i++) {
			$memberDN = $attributeArray[$i];
			$members[] = $memberDN;
			if ($this->connector->isGroupDN($memberDN))
				$members = array_merge($members, $this->connector->getGroupDecendentDNs( $memberDN));
		}
		return $members;
	}

	/**
	 * Answer true if this object is a group
	 *
	 * @return boolean
	 * @access public
	 * @since 3/30/09
	 */
	public function isGroup () {
		return true;
	}

	/**
	 * Answer the values of an attribute
	 *
	 * @param string $attribute The Ldap key for an attribute
	 * @return array
	 * @access protected
	 * @since 3/30/09
	 */
	protected function getLdapAttributeValues ($attribute) {
		$attribute = strtolower($attribute);

		if ($attribute == 'member')
			return $this->members;

		return parent::getLdapAttributeValues($attribute);
	}
}
