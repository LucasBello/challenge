# Diretório de relatórios
REPORTS_DIR=./reports
# Nome da imagem Docker da aplicação para escaneamento
IMAGE_NAME := challenge

# MELHORIA 1: Alvo único para criar o diretório de relatórios
# Evita repetição de mkdir em cada alvo individual
prepare:
	@mkdir -p $(REPORTS_DIR)

# MELHORIA 2: Usa o 'prepare' para garantir que o diretório de relatórios exista
# Gitleaks - Escaneia segredos no repositório
gitleaks: prepare
	docker compose run --rm gitleaks || true

# Bandit - Verificação de vulnerabilidades no código Python
bandit: prepare
	docker compose run --rm bandit || true

# MELHORIA 3: Separação da etapa de build deixa o processo modular
# Build da imagem da aplicação para análise com Trivy
build:
	docker build -t $(IMAGE_NAME) .

# Trivy - Escaneia vulnerabilidades na imagem Docker
# MELHORIA 4: Trivy agora depende do build para garantir que a imagem exista
trivy: prepare build
	docker compose run --rm trivy trivy image --format json --output /reports/trivy-report.json challenge || true
	
# Alvo completo: roda todas as ferramentas de segurança na sequência
# MELHORIA 5: Nome do alvo final segue padrão claro e intuitivo
all: bandit gitleaks trivy