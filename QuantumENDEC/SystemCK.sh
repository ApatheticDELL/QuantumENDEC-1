echo "System check!"
id=879106404160507996
message="AKR24 system check"
	
curl -v \
-H "Authorization: Bot ODk5MTAyMDcyOTc5NDc2NDkx.YWt4Dg.Lk7JGYGilcNSsXi2IqGQbSPn_rk" \
-H "User-Agent: AKQ" \
-H "Content-Type: application/json" \
-X POST \
-d "{\"content\": \"${message}\"}" \
https://discordapp.com/api/v6/channels/${id}/messages
