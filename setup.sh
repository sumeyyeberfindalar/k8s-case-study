#!/bin/bash
set -e # Hata olursa durdur

echo "=== Kubernetes Case Setup Başlatılıyor ==="

# 1. Cluster Kontrolü ve Kurulumu
echo ">>> ADIM 1: Cluster Kurulumu"
if kind get clusters | grep -q "k8s-case"; then
    echo "'k8s-case' cluster'ı zaten mevcut."
else
    echo "'k8s-case' cluster'ı oluşturuluyor... (Config: kind-config.yaml)"
    kind create cluster --name k8s-case --config kind-config.yaml
fi

echo "Node durumu kontrol ediliyor..."
kubectl get nodes
echo "Cluster altyapısı hazır!"
echo ""

# 2. Ingress Controller Kurulumu
echo ">>> ADIM 2: Ingress Controller Kurulumu"
if [ -f "manifests/00-ingress-controller.yaml" ]; then
    echo "Lokal dosya bulundu, Ingress Controller (Nginx) kuruluyor..."
    kubectl apply -f manifests/00-ingress-controller.yaml
else
    echo "Lokal dosya bulunamadı, internetten çekilerek kuruluyor..."
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
fi

echo "Ingress Controller'ın hazır olması bekleniyor (1-2 dk sürebilir)..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s
echo "Ingress Controller hazır!"
echo ""

echo "Webhook'ların devreye girmesi için 15 saniye bekleniyor..."
sleep 15

echo "Ingress Controller tamamen hazır!"
echo ""

# 3. Uygulama Kurulumu
echo ">>> ADIM 3: Uygulama (Linkding) Kurulumu"
echo "Uygulama manifestleri apply ediliyor..."
kubectl apply -f manifests/01-secret.yaml
kubectl apply -f manifests/02-configmap.yaml
kubectl apply -f manifests/03-pvc.yaml
kubectl apply -f manifests/04-deployment.yaml
kubectl apply -f manifests/05-service.yaml
kubectl apply -f manifests/06-ingress.yaml

echo "Uygulamanın ayağa kalkması bekleniyor..."
kubectl rollout status deployment/linkding --timeout=120s
echo "Uygulama hazır!"
echo ""

# 4. Bilgilendirme
echo ">>> ADIM 4: Bilgilendirme"
echo "KURULUM BAŞARIYLA TAMAMLANDI!"
echo "---------------------------------------------------"
echo "Erişim Adresi: http://linkding.local"
echo "Kullanıcı Adı: admin"
echo "Şifre        : password123"
echo "---------------------------------------------------"
echo "Not: '/etc/hosts' dosyanıza '127.0.0.1 linkding.local' eklediğinizden emin olun."
