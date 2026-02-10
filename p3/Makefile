# Değişkenler 📝
SCRIPTS_DIR     = ./scripts
CONFS_DIR       = ./confs
INSTALL_SCRIPT  = $(SCRIPTS_DIR)/install.sh
SETUP_SCRIPT    = $(SCRIPTS_DIR)/setup_app.sh
GIT_REPO_URL	= git@github.com:modoglu/i_o_t.git
ARGOCD_NS       = argocd
TIMEOUT         = 300s

all: install git-push login deploy

install:
	@echo "🔧 Kurulum betiklerine izin veriliyor..."
	@chmod +x $(INSTALL_SCRIPT) $(SETUP_SCRIPT)
	@echo "🚀 install.sh çalıştırılıyor (k3d ve araçlar)..."
	@./$(INSTALL_SCRIPT)

setup:
	@echo "🏗️ Argo CD ve Namespace yapılandırması başlatılıyor..."
	@./$(SETUP_SCRIPT)

login: setup
	@echo "🔑 Şifre alınıyor ve kaydediliyor..."
	@kubectl -n $(ARGOCD_NS) get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode > password.txt
	@echo "" >> password.txt
	@echo "⏳ Argo CD podlarının hazır olması bekleniyor (Limit: $(TIMEOUT))..."
	@kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n $(ARGOCD_NS) --timeout=$(TIMEOUT)
	@echo "🔌 Port-forward başlatılıyor..."
	@kubectl -n $(ARGOCD_NS) port-forward svc/argocd-server 8080:443 &
	@echo "⏳ Tünelin oturması bekleniyor..."
	@sleep 10
	@echo "🔐 Argo CD CLI girişi yapılıyor..."
	@argocd login localhost:8080 --username admin --password $$(cat password.txt) --insecure

deploy:
	@echo "🚀 Uygulama (Application) Argo CD'ye tanıtılıyor..."
	@kubectl apply -f $(CONFS_DIR)/application.yaml

status:
	@echo "📊 Cluster durumu:"
	@kubectl get nodes
	@echo "\n📦 Pod durumları ($(ARGOCD_NS)):"
	@kubectl get pods -n $(ARGOCD_NS)
	@echo "\n📦 Pod durumları (dev):"
	@kubectl get pods -n dev

clean:
	@echo "🗑️ k3d cluster siliniyor..."
	@k3d cluster delete mycluster
	@rm -f password.txt

git-push:
	@echo "📤 Dosyalar GitHub'a gönderiliyor..."
	git add $(CONFS_DIR)/deployment.yaml $(CONFS_DIR)/service.yaml
	git commit -m "Update application manifests to v1"
	git push origin master

.PHONY: all install setup login deploy status clean git-push