echo ""
echo "============================================================"
echo " 🛠️  CONFIGURANDO AMBIENTE DA VM PARA DOCKER"
echo "============================================================"
echo ""

echo "🔄 Atualizando pacotes..."
sudo yum update -y && sudo yum upgrade -y

echo "🐳 Instalando Docker..."
sudo yum install -y docker.io

echo "📦 Ativando o serviço do Docker..."
sudo systemctl enable docker
sudo systemctl start docker

echo "👤 Adicionando o usuário atual ao grupo do Docker..."
sudo usermod -aG docker $USER

echo ""
echo "✅ Docker instalado e pronto para uso!"
echo "⚠️  Saia e entre novamente no terminal para aplicar o grupo 'docker'."
echo ""