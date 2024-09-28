CREATE TEMP FUNCTION hexToTron(address STRING)
RETURNS STRING
LANGUAGE js
OPTIONS (library=["gs://blockchain-etl-bigquery/ethers.js"])
AS r"""
  function encode58(buffer) {
    const ALPHABET = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    const digits = [0];
    for (let i = 0; i < buffer.length; i++) {
      for (let j = 0; j < digits.length; j++) digits[j] <<= 8;
      digits[0] += buffer[i];
      let carry = 0;
      for (let j = 0; j < digits.length; ++j) {
        digits[j] += carry;
        carry = (digits[j] / 58) | 0;
        digits[j] %= 58;
      }
      while (carry) {
        digits.push(carry % 58);
        carry = (carry / 58) | 0;
      }
    }
    for (let i = 0; buffer[i] === 0 && i < buffer.length - 1; i++) digits.push(0);
    return digits.reverse().map((digit) => ALPHABET[digit]).join("");
  }
  function sha256(msgBytes) {
    const msgHex = ethers.utils.hexlify(msgBytes);
    const hashHex = ethers.utils.sha256(msgHex);
    return ethers.utils.arrayify(hashHex);
  }
  addressBytes = ethers.utils.arrayify('0x' + address.replace(/^0x/, '41'))
  checkSum = sha256(sha256(addressBytes)).slice(0, 4);
  return encode58(new Uint8Array([...addressBytes, ...checkSum]));
""";

WITH transfers AS (
  SELECT
    b.block_number,
    hexToTron(CONCAT('0x', SUBSTR(l.topics[1], 27))) AS from_address,
    hexToTron(CONCAT('0x', SUBSTR(l.topics[2], 27))) AS to_address,
    CAST(l.data AS INT64) / 1000000 AS amount
  FROM
    `spider2-public-data.goog_blockchain_tron_mainnet_us.blocks` b
    JOIN
    `spider2-public-data.goog_blockchain_tron_mainnet_us.logs` l
    ON b.block_hash = l.block_hash
  WHERE
    l.address = '0xa614f803b6fd780986a42c78ec9c7f77e6ded13c' -- USDT contract
    AND ARRAY_LENGTH(l.topics) = 3
    AND l.topics[0] = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' -- Transfer events
)
SELECT * FROM transfers ORDER BY amount DESC LIMIT 3;