SELECT c.name, m.name
FROM sys.service_contract_message_usages AS u
INNER JOIN sys.service_contracts AS c ON u.service_contract_id = c.service_contract_id
INNER JOIN sys.service_message_types AS m ON u.message_type_id = m.message_type_id

SELECT s.name, c.name FROM sys.service_contract_usages AS u
INNER JOIN sys.services AS s ON u.service_id = s.service_id
INNER JOIN sys.service_contracts AS c ON u.service_contract_id = c.service_contract_id