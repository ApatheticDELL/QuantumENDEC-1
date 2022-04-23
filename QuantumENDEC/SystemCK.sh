echo "System check!"
id=
message="AKR24 system check"
	
curl -v \
-H "Authorization: Bot" \
-H "User-Agent: AKQ" \
-H "Content-Type: application/json" \
-X POST \
-d "{\"content\": \"${message}\"}" \
https://discordapp.com/api/v6/channels/${id}/messages
