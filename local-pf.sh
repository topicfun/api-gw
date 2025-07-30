#!/bin/sh

echo "Port-forwarding munkamenetek indítása a háttérben..."
echo "A kimenet a logfájlokba lesz átirányítva, vagy elvetve."

# Minden parancs végén az '&' jel háttérbe küldi.
# A '> /dev/null 2>&1' átirányítja a standard kimenetet és hibakimenetet
# a /dev/null-ba, így nem jelennek meg a terminálban.
# Ha szeretnéd látni a kimenetet, de külön fájlba, akkor "> forward_logs.log 2>&1"-re cseréld.

kubectl port-forward service/int-gw-internal-api-gateway 58080:80 > /dev/null 2>&1 & \
kubectl port-forward service/dxl-sec-id-profile-svc 58081:8080 > /dev/null 2>&1 & \
kubectl port-forward service/dxl-sgw-sim-svc 58082:8080 > /dev/null 2>&1 & \
kubectl port-forward service/alb-redis 56379:6379 > /dev/null 2>&1 & \
kubectl port-forward service/alb-redis 56380:26379 > /dev/null 2>&1 & \
kubectl port-forward service/alb-dxl-db-rw 15432:5432 > /dev/null 2>&1 & \
kubectl port-forward service/strapi-sandbox 58083:8080 > /dev/null 2>&1 & \
kubectl port-forward service/dxl-party-role-tmf669 58084:8080  > /dev/null 2>&1 & \
kubectl port-forward service/wiremock-service 58085:80  > /dev/null 2>&1 &
kubectl port-forward service/strapi-sandbox 58086:5432 > /dev/null 2>&1 & \
kubectl port-forward service/dxl-product-offering-filter 58087:8080 > /dev/null 2>&1 &




#temp-jd-alerant
#kubectl port-forward service/dxl-party-role-tmf669 58084:8080 -n jd-alb-sit &
#kubectl port-forward service/dxl-party-role-tmf669 58084:8080 -n jd-alb-sit > /dev/null 2>&1 &
#kubectl port-forward service/dxl-party-role-tmf669 58085:8080  > /dev/null 2>&1 &
#kubectl port-forward service/dxl-party-role-tmf669 58086:8080  > /dev/null 2>&1 &


echo "indítási parancs:"
echo "source ./local-pf.sh"
echo "A port-forwarding parancsok elindultak. A terminál prompt azonnal visszatér."
echo "A futó háttérfolyamatok listázásához használd a 'jobs' parancsot."
echo "A folyamatok leállításához használd a 'kill <PID>' parancsot."
echo "Ne feledd, a terminál bezárása leállíthatja ezeket a folyamatokat, kivéve, ha 'nohup'-pal indítottad őket."