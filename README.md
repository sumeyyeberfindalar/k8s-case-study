# Kubernetes Kurulum ve Otomasyon Case Study

Bu proje; yerel bir Kubernetes kümesinin (Kind) otomasyonla ayağa kaldırılması, açık kaynaklı bir uygulamanın (Linkding) tüm bileşenleriyle deploy edilmesi ve  Rolling Update & Rollback operasyonlarının bir CI/CD pipeline üzerinden doğrulanmasını içerir.

## Mimari ve Teknoloji Tercihleri

* **Kubernetes Ortamı:** `Kind (Kubernetes in Docker)` - Hafif yapısı ve GitHub Actions ile entegrasyonu nedeniyle seçilmiştir.
* **Ingress Controller:** `Nginx Ingress` - Standart bir trafik yönetimi sağlamak amacıyla `kind-config.yaml` üzerinden `extraPortMappings` (80/443) ile yapılandırılmıştır.
* **Uygulama:** `Linkding` - Python tabanlı ve Stateful (PVC gerektiren) bir uygulama olduğu için Kubernetes yeteneklerini sergilemek amacıyla tercih edilmiştir.
* **CI/CD:** `GitHub Actions` - Her push işleminde Docker imajını derler ve otomatik olarak E2E testlerini koşturur.

## Gereksinimler

Projenin yerel ortamda çalışması için şunlar gereklidir:

* **Docker**
* **Kind** (v0.31.0 önerilir)
* **Kubectl**

> **Önemli Not:** Uygulamaya erişebilmek için `/etc/hosts` dosyanıza şu satırı eklemelisiniz:
> `127.0.0.1 linkding.local`

## Kurulum (Setup)

Tüm altyapıyı (Cluster, Ingress, App) tek seferde ayağa kaldırmak için:

```bash
chmod +x setup.sh
./setup.sh

```

*Script tamamlandığında `http://linkding.local` adresinden uygulamaya erişebilirsiniz.*

## Update & Rollback Operasyonları 

`update.sh` scripti, uygulamanın kesintisiz bir şekilde güncellenmesini ve hata durumunda geri alınmasını simüle eder.

**Kullanım:**

* **Varsayılan:** `./update.sh` (İmajı 1.45.0 versiyonuna günceller).
* **Dinamik:** `./update.sh custom-image:tag` (İstenilen bir imajı parametre olarak alır).

*Bu süreçte `kubectl watch` mekanizmasıyla podların durum geçişleri terminalde canlı olarak izlenebilir.*

## CI/CD Akışı

Proje, GitHub Actions üzerinde şu adımları otomatik olarak gerçekleştirir:

1. **Build & Push:** Dockerfile kullanılarak imaj derlenir.
2. **Infrastructure as Code:** `kind-config.yaml` ile geçici bir cluster kurulur.
3. **Validation:** `setup.sh` ve `update.sh` scriptleri çalıştırılarak kurulum ve güncelleme süreçleri test edilir.

## Bilinen Sorunlar ve Çözümler

* **Ingress Webhook Hatası:** Ingress Controller ilk kurulduğunda Webhook servisi birkaç saniye `Connection Refused` hatası verebilmektedir. Bu durum `setup.sh` içerisine eklenen **15 saniyelik bekleme süresi** ile çözülmüştür.
* **Graceful Shutdown:** `update.sh` sırasında eski podların bir süre daha `Running` görünmesi, Kubernetes'in 30 saniyelik Grace Period sürecinden kaynaklanmaktadır. Bu durum script içerisindeki bekleme süreleriyle senkronize edilmiştir.
