This service is responsible for generating unique IDs. This follows the Snowflake algorithm.
- timestamp
- machine ID
- sequence

Considering there is a high request rate, the problem is having duplicated code generated from race condittions.