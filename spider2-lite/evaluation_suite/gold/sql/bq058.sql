-- UDF for easier string manipulation.
CREATE TEMP FUNCTION ParseSubStr(hexStr STRING, startIndex INT64, endIndex INT64)
RETURNS STRING
LANGUAGE js
AS r"""
  if (hexStr.length < 1) {
    return hexStr;
  }
  return hexStr.substring(startIndex, endIndex);
""";

-- UDF to translate hex numbers into decimal representation.
CREATE TEMP FUNCTION HexToDec(hexStr STRING)
RETURNS BIGNUMERIC
LANGUAGE js
AS r"""
   return parseInt(hexStr, 16)
""";

-- UDF to strip leading zeroes from 66 character addresses.
-- Optimism addresses as returned from the OP node are 66 characters long.
-- Format: "0x" prefix + 64 character (32-byte) address.
-- Strip the leading zeroes so that it's easier to look up addresses in block explorer.
CREATE TEMP FUNCTION StripLeadingZeroes(hex STRING, numZeroes INT64)
RETURNS STRING
LANGUAGE js
AS r"""
  function _stripLeadingZeroes(addr, numZeroes) {
    if (addr.length != 66) {
      return addr;
    }
    return '0x'.concat(addr.substring(numZeroes));
  }
  return _stripLeadingZeroes(hex, numZeroes);
""";

-- Find finalized deposits into Optimism (L2) where assets were transferred
-- from the L1 (Ethereum) to the L2 (Optimism) via the Optimism Standard Bridge
-- at block X.
SELECT
  transaction_hash,
  CONCAT("https://optimistic.etherscan.io/tx/", transaction_hash) AS txn_optimistic_etherscan,
  StripLeadingZeroes(topics[OFFSET(1)], 26) AS L1Token,
  StripLeadingZeroes(topics[OFFSET(2)], 26) AS L2Token,
  StripLeadingZeroes(topics[OFFSET(3)], 26) AS from_address,
  StripLeadingZeroes(ParseSubStr(l.data, 0, 66), 26) AS to_address,
  HexToDec(ParseSubStr(l.data, 66, 130)) AS amount_deposited,
FROM
  `bigquery-public-data.goog_blockchain_optimism_mainnet_us.logs` as l
WHERE
  ARRAY_LENGTH(l.topics) > 0 -- Check for non-empty topics first to short-circuit boolean evaluation.
AND
  -- DepositFinalized:
  -- https://github.com/ethereum-optimism/optimism/blob/e24d77204ede3635d57253f5b6306be261e109b5/packages/contracts-ts/abis.json#L10319
  l.topics[OFFSET(0)] = "0xb0444523268717a02698be47d0803aa7468c00acbed2f8bd93a0459cde61dd89"
AND
  block_number = 109223310;