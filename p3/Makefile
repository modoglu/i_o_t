SCRIPTS_DIR     = ./scripts
CONFS_DIR       = ./confs
INSTALL_SCRIPT  = $(SCRIPTS_DIR)/install.sh
SETUP_SCRIPT    = $(SCRIPTS_DIR)/setup_app.sh
ARGOCD_NS       = argocd
TIMEOUT         = 300s

USER            = modoglu
REPO            = i_o_t
TARGET_REPO_URL = github.com/$(USER)/$(REPO).git
TOKEN          ?= $(GITHUB_TOKEN)

all: install login git-push deploy

install:
	@echo "🔧 Kurulum betiklerine izin veriliyor..."
	@chmod +x $(INSTALL_SCRIPT) $(SETUP_SCRIPT)
	@echo "🚀 install.sh çalıştırılıyor..."
	@$(INSTALL_SCRIPT)

setup:
	@echo "🏗️ Argo CD yapılandırması..."
	@./$(SETUP_SCRIPT)

login: setup
	@echo "🔑 Şifre alınıyor..."
	@kubectl -n $(ARGOCD_NS) get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode > password.txt
	@echo "" >> password.txt
	@kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n $(ARGOCD_NS) --timeout=$(TIMEOUT)
	@kubectl -n $(ARGOCD_NS) port-forward svc/argocd-server 8080:80 > /dev/null 2>&1 &
	@sleep 10
	@argocd login localhost:8080 --username admin --password $$(cat password.txt) --insecure

git-push:
	@if [ -z "$(TOKEN)" ]; then \
		echo "❌ GITHUB_TOKEN tanımlı değil. Örnek: export GITHUB_TOKEN=ghp_... sonra make git-push"; \
		exit 1; \
	fi
	@echo "📤 DevOps Otomasyonu: Hedef repo zorlanıyor..."
	@git config --local user.name "$(USER)"
	@git config --local user.email "$(USER)@example.com"
	@git add .
	@git commit -m "Automated Update: $$(date)" || true
	@git push --force https://$(USER):$(TOKEN)@$(TARGET_REPO_URL) main || (echo "❌ Push başarısız! Token (repo) ve branch adını kontrol edin." && exit 1)

deploy:
	@echo "🚀 Uygulama Argo CD'ye tanıtılıyor..."
	@kubectl apply -f $(CONFS_DIR)/application.yaml

clean:
	@k3d cluster delete mycluster
	@rm -f password.txt

.PHONY: all install setup login deploy status clean git-push
