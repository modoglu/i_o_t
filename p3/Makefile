# Değişkenler 📝
SCRIPTS_DIR     = ./scripts
CONFS_DIR       = ./confs
INSTALL_SCRIPT  = $(SCRIPTS_DIR)/install.sh
SETUP_SCRIPT    = $(SCRIPTS_DIR)/setup_app.sh
ARGOCD_NS       = argocd
TIMEOUT         = 300s

TOKEN           = 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
REPO_URL        = github.com/modoglu/i_o_t.git
USER_NAME       = modoglu
USER_EMAIL      = eminmodogluxox@gmail.com

all: install login git-push deploy

install:
	@echo "🔧 Kurulum betiklerine izin veriliyor..."
	@chmod +x $(INSTALL_SCRIPT) $(SETUP_SCRIPT)
	@echo "🚀 install.sh çalıştırılıyor (k3d ve araçlar)..."
	@$(INSTALL_SCRIPT)

setup:
	@echo "🏗️ Argo CD ve Namespace yapılandırması başlatılıyor..."
	@./$(SETUP_SCRIPT)

login: setup
	@echo "🔑 Şifre alınıyor ve kaydediliyor..."
	@kubectl -n $(ARGOCD_NS) get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode > password.txt
	@echo "" >> password.txt
	@echo "⏳ Argo CD podlarının hazır olması bekleniyor (Limit: $(TIMEOUT))..."
	@kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n $(ARGOCD_NS) --timeout=$(TIMEOUT)
	@echo "🔌 Port-forward başlatılıyor (HTTP 80 portuna)..."
	@kubectl -n $(ARGOCD_NS) port-forward svc/argocd-server 8080:80 > /dev/null 2>&1 &
	@echo "⏳ Tünelin oturması bekleniyor..."
	@sleep 10
	@echo "🔐 Argo CD CLI girişi yapılıyor..."
	@argocd login localhost:8080 --username admin --password $$(cat password.txt) --insecure

git-push:
	@echo "📤 DevOps Otomasyonu: Git kimlik bilgileri yerel olarak ayarlanıyor..."
	@git config --local user.name "$(USER_NAME)"
	@git config --local user.email "$(USER_EMAIL)"
	@echo "🚀 Dosyalar i_o_t reposuna token ile gönderiliyor..."
	@git add .
	@git commit -m "Automated DevOps Update: $$(date)" || true
	@git push --force https://$(TOKEN)@$(REPO_URL) main || (echo "⚠️ Push başarısız! Token yetkilerini (repo scope) kontrol edin." && exit 1)

deploy:
	@echo "🚀 Uygulama (Application) Argo CD'ye tanıtılıyor..."
	@kubectl apply -f $(CONFS_DIR)/application.yaml
	@echo "✅ Her şey hazır! Argo CD üzerinden senkronizasyonu takip edebilirsiniz."

status:
	@echo "📊 Cluster durumu:"
	@kubectl get nodes
	@echo "\n📦 Pod durumları ($(ARGOCD_NS)):"
	@kubectl get pods -n $(ARGOCD_NS)

clean:
	@echo "🗑️ k3d cluster siliniyor..."
	@k3d cluster delete mycluster
	@rm -f password.txt

.PHONY: all install setup login deploy status clean git-push