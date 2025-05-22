# $DEVOPS-TOOLS-CLOUD-COMPUTING$

```
DEVOPS-TOOLS-CLOUD-COMPUTING/
├── CLI-command/
│   └── comandos.sh
├── java-docker/
│   └── projeto java
├── net-docker/
│   └── projeto .NET
├── diagram/
│   └── desenho da arquitetura
├── images/
│   └── print de evidência
├── README.md
└── pdf de entrega

```

# DEVOPS-CLOUD-SPRINT01

## **Objetivo**

Desenvolver uma aplicação que faça a leitura de um IOT anexo nas motos da MOTTU, e por meio da conexão WI-FI, triangular a localização dela nos patios.

Em ASP.NET, será implementado 2 funções:

1. Produção de API RESTful, para relacionamento com o banco de dado ORACLE.
2. Arquitetura MVC que retorna as entidade em formato de tabela com as funções do CRUD.
3. Criar **Grupo de Recursos** e **VM** na Microsoft Azure.
4. Containização da aplicação em VM Linux.

> Ao terminar os testes o grupo de recursos sera excluído.

---

## **IAAS - Microsoft Azure**

Para uso da aplicação ASP.NET, foi criado uma maquina virtual Linux que terá o Docker instalado e receberá a nossa imagem personalizada.

> Todo o desenvolvimento ocorre feio por azure CLI e comandos automatizados por shell script.

### **Criar a VM**

- Script para [Criar VM](create_all.sh)

1. **Inicia criando um grupo de recursos que vai armazenar a nossa VM**

```sh
# Comando para se criar um grupo de recussos
az group create --name rg-mottu --location brazilsouth --tags environment-mottu
```

2. **Cria a VM Linux**

```sh

az vm create \
    --name vm-lnx-mottu \
    --resource-group rg-mottu \
    --accelerated-networking false \
    --accept-term \
    --additional-events false \
    --admin-password Mottu@2tdsvms \
    --admin-username admMottu \
    --authentication-type password \
    --computer-name mottu-01 \
    --enable-agent true \
    --enable-auto-update true \
    --enable-hibernation false \
    --enable-redeploy true \
    --image almalinux:almalinux-x86_64:9-gen2:latest \
    --location brazilsouth \
    --nic-delete-option Delete \
    --nsg-rule SSH \
    --os-disk-delete-option Delete \
    --os-disk-name mottu-disk \
    --patch-mode ImageDefault \
    --priority Spot \
    --size Standard_B2ats_v2 \
    --tags environment-mottu \
    --ultra-ssd-enabled false \
    --zone 1

```

3. **Abrir as portas necessarias**

```sh
az vm open-port --port 80 -g rg-mottu \
    -n vm-lnx-mottu --priority 1100

az vm open-port --port 443 -g rg-mottu \
    -n vm-lnx-mottu --priority 1200

az vm open-port --port 8080 -g rg-mottu \
    -n vm-lnx-mottu --priority 1300
```

4. _Bonus - desligar de forma automatica a VM_

```sh
az vm auto-shutdown -g rg-mottu -n vm-lnx-mottu --time 2359 --email "francescomdibe@gmail.com"
```

### **Instalar o Docker**

- Script para [Instalar o Docker](install_docker.sh)

1. **Atualizando pacotes**

```sh
sudo yum update -y && sudo yum upgrade -y
```

2. **Instalar Docker**

```sh
sudo yum install -y docker.io
```

3. Ativar o serviço do Docker

```sh
sudo systemctl enable docker
sudo systemctl start docker
```

4. Adicionar o usuário atual ao grupo do Docker

```sh
sudo usermod -aG docker $USER
```

> Após esse passo é necessário sair do terminal e entrar novamente

### **Criar Container**

- Script para [Criar o container](create_docker.sh)

O projeto APS.NET e suas dependências estão na pasta de deploy, junto ao Dockerfile.

1. **Entrar na pasta deploy**

```sh
cd net-docker
cd deploy

CAMINHO=$(pwd) # Variável para armazenar o diretório atual
```

2. **Credenciais do oracle**

Para realizar acesso ao bando de dados oracle, deve-se informar Login e Senha

```sh
read -p "RM: " ID
read -s -p "Senha: " PASSWORD
```

3. **Criar a rede virtual**

Ela é necessária para que tenha a comunicação entre os container dentro da VM.

```sh
docker network create mottu-net
docker network ls
```

4. **build da imagem que contem a aplicação**

```sh
docker build -t mottu-oracle .
```

Dentro da pasta deploy temos também nosso `Dockerfile` com as '_instruções_' de como o docker deve criar a imagem.

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0

WORKDIR /app

COPY . .

EXPOSE 8080

ENTRYPOINT ["dotnet", "mottu.dll"]
```

<!-- Vou precisar de ajuda nessa parte harleen-->

| Código                                   | Funcão                                                                     |
| ---------------------------------------- | -------------------------------------------------------------------------- |
| FROM mcr.microsoft.com/dotnet/aspnet:8.0 | Usa a imagem ASP.NET runtime pronta                                        |
| WORKDIR /app                             | Define que /app será a pasta de trabalho no container                      |
| COPY . .                                 | Copia os arquivos da pasta onde está o Dockerfile para dentro do container |
| EXPOSE 8080                              | Informa qual porta a aplicação vai escutar                                 |
| ENTRYPOINT ["dotnet", "mottu.dll"]       | Roda o dotnet mottu.dll, que é a aplicação ASP.NET compilada               |

#### **_Por que tão simples?_**

Ao se fazer o `publish` da aplicação, você diz "_Compila tudo e me retorna a versão final (mottu.dll + dependências)_"

```powershell
dotnet publish -c Release -o ./deploy
```

Aplicação já está configurada para conectar externamente à FIAP (oracle.fiap.com.br:1521/orcl)

Isso funciona direto com internet, sem necessidade de rodar um Oracle dentro da VM.



### **Iniciar o container que irá rodar em segundo plano**

```sh
docker run -d -p 8080:8080 -v $CAMINHO:/app --name mottu-oracle mottu-oracle
```

### **Controle**

Para conferir se tudo está certo, podemos ver as imagens que tem no Docker e container que estão ativos.

```sh
docker image ls

docker ps
```

## **Aplicação ASP.NET**

Projeto iniciado com o uso de 2 entidade:

### **Filial**

| Atributo             | Tipo         | Obrigatório? | Observação                           |
| :------------------- | :----------- | :----------- | :----------------------------------- |
| **id_filial**        | INT          | Sim (PK)     | Identificador único da filial        |
| **nome_filial**      | VARCHAR(100) | Sim          | Nome da filial                       |
| **endereco**         | VARCHAR(255) | Sim          | Endereço completo da filial          |
| **cidade**           | VARCHAR(100) | Sim          | Cidade onde a filial está localizada |
| **estado**           | VARCHAR(50)  | Sim          | Estado onde a filial está localizada |
| **pais**             | VARCHAR(50)  | Sim          | País onde a filial está localizada   |
| **cep**              | VARCHAR(20)  | Opcional     | Código postal (CEP) da filial        |
| **telefone**         | VARCHAR(20)  | Opcional     | Telefone de contato da filial        |
| **data_inauguracao** | DATE         | Opcional     | Data de inauguração da filial        |

<details>
  <summary><b>Tabela</b></summary>

```SQL
CREATE TABLE T_CM_FILIAL
    (
     ID_FILIAL      INTEGER  NOT NULL ,
     NM_FILIAL      VARCHAR2 (100)  NOT NULL ,
     DS_ENDERECO    VARCHAR2 (255)  NOT NULL ,
     DS_CIDADE      VARCHAR2 (100)  NOT NULL ,
     DS_ESTADO      VARCHAR2 (50)  NOT NULL ,
     DS_PAIS        VARCHAR2 (50)  NOT NULL ,
     CD_CEP         VARCHAR2 (20) ,
     DS_TELEFONE    VARCHAR2 (20) ,
     DT_INAUGURACAO DATE
    )
    LOGGING
;
```

</details>

### **Pátio**

| Atributo           | Tipo         | Obrigatório? | Observação                                      |
| :----------------- | :----------- | :----------- | :---------------------------------------------- |
| **id_patio**       | INT          | Sim (PK)     | Identificador único do pátio                    |
| **id_filial**      | INT          | Sim (FK)     | Filial à qual o pátio pertence                  |
| **nome_patio**     | VARCHAR(100) | Sim          | Nome ou identificação do pátio                  |
| **capacidade_max** | NUMBER(5)    | Opcional     | Quantidade máxima de motos que o pátio comporta |
| **area_m2**        | NUMBER(6,2)  | Opcional     | Área do pátio em metros quadrados               |
| **descricao**      | TEXT         | Opcional     | Descrição adicional sobre o pátio               |

<details>
  <summary><b>Tabela</b></summary>

```sql
CREATE TABLE T_CM_PATIO
    (
     ID_PATIO      INTEGER  NOT NULL ,
     ID_FILIAL     INTEGER  NOT NULL ,
     NM_PATIO      VARCHAR2 (100)  NOT NULL ,
     NR_CAP_MAX    NUMBER (5) ,
     VL_AREA_PATIO NUMBER (6,2) ,
     DS_OBS        CLOB
    )
    LOGGING
;
```

</details>

---

## **API RESTful (Swagger disponível)**

### **Filial API**

| Método | Rota                  | Descrição              |
| ------ | --------------------- | ---------------------- |
| GET    | `/api/FilialApi`      | Lista todas as filiais |
| GET    | `/api/FilialApi/{id}` | Busca filial por ID    |
| POST   | `/api/FilialApi`      | Cria nova filial       |
| PUT    | `/api/FilialApi/{id}` | Atualiza filial        |
| DELETE | `/api/FilialApi/{id}` | Remove filial          |

### **Pátio API**

| Método | Rota                 | Descrição             |
| ------ | -------------------- | --------------------- |
| GET    | `/api/PatioApi`      | Lista todos os pátios |
| GET    | `/api/PatioApi/{id}` | Busca pátio por ID    |
| POST   | `/api/PatioApi`      | Cria novo pátio       |
| PUT    | `/api/PatioApi/{id}` | Atualiza pátio        |
| DELETE | `/api/PatioApi/{id}` | Remove pátio          |

![API](./img/API's.png)

> https://ip_VM:xxxx/swagger — documentação da API

---

## **Aplicação MVC**

Foi criado um modelo CRUD, Create, Read, Update, Delete para "Filial" e "Patio".

![Link do video](link do video)


## **Como rodar o projeto**

1. [Criar VM](create_all.sh)
2. Download do repositório na vm

```url
https://github.com/Entrega-CheckPoint/DEVOPS-CLOUD-SPRINT01
```

3. [Instalar docker](create_all.sh)
4. [Criar o container](create_all.sh)

## **Termino da simulação**

Ao se terminar a simulação, foi excluído todo o grupo de recursos.

```sh
az group delete --name rg-test -y
```

### **Limpar o Docker**

Caso queira parar todos os container e limpar o docker

```sh
docker stop $(docker ps -aq)

docker system prune -a -f --volumes
```
