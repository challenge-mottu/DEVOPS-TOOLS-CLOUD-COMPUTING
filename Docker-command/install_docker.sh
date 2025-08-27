echo ""
echo "============================================================"
echo " 🛠️  INSTALANDO DOCKER NO ALMALINUX "
echo "============================================================"
echo ""

echo "🔄 Atualizando pacotes..."
sudo yum update -y

echo "📦 Instalando dependências..."
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

echo "Adicionando repositório oficial do Docker..."
sudo yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

echo "Instalando o Docker Engine..."
sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

echo "Habilitando e iniciando serviço do Docker..."
sudo systemctl enable docker
sudo systemctl start docker

echo "👤 Adicionando o usuário atual ao grupo docker..."
sudo groupadd docker
sudo usermod -aG docker $USER

echo ""
echo "✅ Docker instalado com sucesso!"
echo "⚠️  Saia e entre novamente na sessão (ou use 'newgrp docker') para ativar a permissão."
