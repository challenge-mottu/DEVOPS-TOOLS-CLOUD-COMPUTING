# Escopo para criar todo grupo de recurso

az login

# Comando para se criar um grupo de recussos
az group create --name rg-test --location brazilsouth --tags environment-test


# AlmaLinux é leve, compatível com Red Hat e gratuito
# Mesmo sistema que nossa VM FREE da aula, podemos subir os testes nela
az vm create \
    --name vm-lnx-test \
    --resource-group rg-test \
    --accelerated-networking false \
    --accept-term \
    --additional-events false \
    --admin-password Test@2tdsvms \
    --admin-username admtest \
    --authentication-type password \
    --computer-name test-01 \
    --enable-agent true \
    --enable-auto-update true \
    --enable-hibernation false \
    --enable-redeploy true \
    --image almalinux:almalinux-x86_64:9-gen2:latest \
    --location brazilsouth \
    --nic-delete-option Delete \
    --nsg-rule SSH \
    --os-disk-delete-option Delete \
    --os-disk-name test-disk \
    --patch-mode ImageDefault \
    --priority Spot \
    --size Standard_B2ats_v2 \
    --tags environment-test \
    --ultra-ssd-enabled false \
    --zone 1

# Abrir as portas necessarias

az vm open-port --port 80 -g rg-test \
    -n vm-lnx-test --priority 1100

az vm open-port --port 443 -g rg-test \
    -n vm-lnx-test --priority 1200

az vm open-port --port 8080 -g rg-test \
    -n vm-lnx-test --priority 1300

# desligar de forma automatica a VM
az vm auto-shutdown -g rg-test -n vm-lnx-test --time 2359 --email "francescomdibe@gmail.com"
