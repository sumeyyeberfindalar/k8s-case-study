# Kubernetes Kurulum ve Otomasyon Case Study

Bu proje, yerel bir Kubernetes kümesinin (Kind kullanılarak) sıfırdan ayağa kaldırılması, açık kaynaklı bir uygulamanın (Linkding) deploy edilmesi ve Rolling Update & Rollback otomatikleştirilmesini içermektedir.

## Mimari ve Teknoloji Tercihleri

* **Kubernetes Ortamı:** `Kind (Kubernetes in Docker)` - Hafif, hızlı ve CI/CD süreçlerine (GitHub Actions) native entegrasyonu sebebiyle tercih edilmiştir.
* **Uygulama:** `Linkding` - Python (Django) tabanlı hafif bir bookmark yöneticisi. Minimal kaynak tüketimi ve net konfigürasyon yapısı (Secret/ConfigMap) nedeniyle seçilmiştir.

## Gereksinimler

Bu projeyi kendi ortamınızda çalıştırmak için aşağıdaki araçların yüklü olması gerekmektedir:
* Docker
* Kind (`v0.20.0` veya üzeri)
* Kubectl

> **Önemli Not:** Local ortamdan Ingress üzerinden uygulamaya erişebilmek için `/etc/hosts` dosyanıza şu satırı eklemelisiniz:
> `127.0.0.1 linkding.local`

## Kurulum (Bölüm A, B, C)

Kurulum süreci tamamen otomatikleştirilmiştir. Aşağıdaki komutu çalıştırarak Cluster, Ingress Controller ve Uygulama manifestlerini sırasıyla ayağa kaldırabilirsiniz:

```bash
chmod +x setup.sh
./setup.sh

```

*Script tamamlandığında uygulamaya `http://linkding.local` adresinden (Kullanıcı adı: admin, Şifre: password123) erişebilirsiniz.*

Deployment sonrası imaj güncelleme (Rolling Update) ve hata durumunda geri alma (Rollback) süreçlerini canlı olarak simüle etmek için aşağıdaki scripti çalıştırabilirsiniz. 

Script varsayılan olarak `1.45.0` imajına günceller, ancak isterseniz dışarıdan dinamik bir imaj (örneğin CI/CD pipeline'ından gelen imajı) parametre olarak verebilirsiniz:

**Varsayılan İmaj ile Çalıştırmak İçin:**
```bash
chmod +x update.sh
./update.sh
```

**Farklı/Dinamik Bir İmaj ile Çalıştırmak İçin:**

```bash
./update.sh sissbruecker/linkding:latest

```
*Bu script, Kubernetes custom-columns kullanarak pod geçişlerini (Zero-Downtime) terminal üzerinde canlı (watch) olarak listeler.*
