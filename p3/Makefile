SCRIPTS_DIR            = ./scripts
CONFS_DIR              = ./confs
INSTALL_SCRIPT         = $(SCRIPTS_DIR)/install.sh
SETUP_SCRIPT           = $(SCRIPTS_DIR)/setup_app.sh
ARGOCD_NS              = argocd
TIMEOUT                = 300s

# DevOps Otomasyon Bilgileri
# NOT: Token'ı URL içine "username:token" formatında gömmek 403 hatasını aşmanın en sağlam yoludur.
# Kullanıcı, depo ve token bilgileri ortam değişkenleriyle veya Make argümanlarıyla override edilebilir.
USER                   ?= modoglu
REPO                   ?= i_o_t
TOKEN                  ?= $(GITHUB_TOKEN)

# Argo CD için kaynak repo adresi (token'sız, yalnızca HTTPS)
TARGET_REPO_HOST_PATH  = github.com/$(USER)/$(REPO)
TARGET_REPO_URL        = https://$(TARGET_REPO_HOST_PATH)

# Git push için kullanılacak tam URL (token gömülü)
GIT_REMOTE_URL         = https://$(USER):$(TOKEN)@$(TARGET_REPO_HOST_PATH).git

all: install login git-push deploy

install:
	@echo "🔧 Kurulum betiklerine izin veriliyor..."
	@chmod +x $(INSTALL_SCRIPT) $(SETUP_SCRIPT)
	@echo "🚀 install.sh çalıştırılıyor..."
	@$(INSTALL_SCRIPT)

setup:
	@echo "🏗️ Argo CD yapılandırması..."
	@./$(SETUP_SCRIPT)
	@echo "🔗 Argo CD application.repoURL güncelleniyor..."
	@sed -i.bak "s#repoURL: 'https://github.com/.*'#repoURL: '$(TARGET_REPO_URL)'#" $(CONFS_DIR)/application.yaml
	@rm -f $(CONFS_DIR)/application.yaml.bak

login: setup
	@echo "🔑 Şifre alınıyor..."
	@kubectl -n $(ARGOCD_NS) get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode > password.txt
	@echo "" >> password.txt
	@kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n $(ARGOCD_NS) --timeout=$(TIMEOUT)
	@kubectl -n $(ARGOCD_NS) port-forward svc/argocd-server 8080:80 > /dev/null 2>&1 &
	@sleep 10
	@argocd login localhost:8080 --username admin --password $$(cat password.txt) --insecure

git-push:
	@echo "📤 DevOps Otomasyonu: scoped git kimlik bilgisi yapılandırılıyor..."
	@git config --local user.name "$(USER)"
	@git config --local user.email "$(USER)@example.com"
	@git config --local credential.helper ""
	@echo "🔍 sync_target remote durumu kontrol ediliyor..."
	@if git remote get-url sync_target >/dev/null 2>&1; then \
		echo "🔄 Mevcut sync_target remote'u güncelleniyor..."; \
		git remote set-url sync_target $(GIT_REMOTE_URL); \
	else \
		echo "➕ Yeni sync_target remote'u ekleniyor..."; \
		git remote add sync_target $(GIT_REMOTE_URL); \
	fi
	@echo "📦 Değişiklikler hazırlanıyor..."
	@git add .
	@git commit -m "Automated DevOps Update: $$(date)" || true
	@echo "🚀 Değişiklikler force push ile senkronlanıyor..."
	@git push --force sync_target main || (echo "❌ Push başarısız! Lütfen TOKEN yetkilerini (Contents: Read & Write) ve URL'yi kontrol edin." && exit 1)

deploy:
	@echo "🚀 Uygulama Argo CD'ye tanıtılıyor..."
	@kubectl apply -f $(CONFS_DIR)/application.yaml

clean:
	@k3d cluster delete mycluster
	@rm -f password.txt

.PHONY: all install setup login deploy status clean git-push