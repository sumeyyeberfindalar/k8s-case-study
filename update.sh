#!/bin/bash
set -e

NEW_IMAGE=${1:-"sissbruecker/linkding:1.45.0"}

echo "=== Bölüm D: Rolling Update ve Rollback Testi ==="

echo ">>> Mevcut image versiyonu:"
kubectl get deployment linkding -o=jsonpath='{$.spec.template.spec.containers[:1].image}'
echo -e "\n"

# Ekrana basılacak formatı belirliyoruz (Pod Adı | Durum | Image)
FORMAT="POD:.metadata.name,STATUS:.status.phase,IMAGE:.spec.containers[0].image"

# ---------------------------------------------------------
# ADIM 1: Rolling Update
# ---------------------------------------------------------
echo ">>> ADIM 1: Yeni versiyona (${NEW_IMAGE}) güncelleniyor (Rolling Update)..."
echo "---------------------------------------------------------------------------"

# Watch komutunu özel sütunlarla arka planda başlat
kubectl get pods -o custom-columns=$FORMAT --watch &
WATCH_PID=$!
sleep 2 

# Güncellemeyi tetikle
kubectl set image deployment/linkding linkding=$NEW_IMAGE > /dev/null

# Güncellemenin bitmesini bekle
kubectl rollout status deployment/linkding >/dev/null 2>&1

sleep 10

# İzlemeyi durdur
kill $WATCH_PID 2>/dev/null || true
echo "---------------------------------------------------------------------------"

echo -e "\n>>> Güncelleme başarılı! Yeni image:"
kubectl get deployment linkding -o=jsonpath='{$.spec.template.spec.containers[:1].image}'
echo -e "\n"
kubectl get pods -o custom-columns=$FORMAT
echo -e "\n"

sleep 4

# ---------------------------------------------------------
# ADIM 2: Rollback (Geri Alma)
# ---------------------------------------------------------
echo ">>> ADIM 2: Eski versiyona dönülüyor (Rollback)..."
echo "---------------------------------------------------------------------------"

# Watch komutunu tekrar başlat
kubectl get pods -o custom-columns=$FORMAT --watch &
WATCH_PID=$!
sleep 2

# Geri almayı tetikle
kubectl rollout undo deployment/linkding > /dev/null

# Geri almanın bitmesini bekle
kubectl rollout status deployment/linkding> /dev/null 2>&1

sleep 10

# İzlemeyi durdur
kill $WATCH_PID 2>/dev/null || true
echo "---------------------------------------------------------------------------"

echo -e "\n>>> Rollback başarıyla tamamlandı! Versiyon tekrar eski haline döndü:"
kubectl get deployment linkding -o=jsonpath='{$.spec.template.spec.containers[:1].image}'
echo -e "\n"
kubectl get pods -o custom-columns=$FORMAT
echo -e "\n"

echo "=== Test Tamamlandı ==="
