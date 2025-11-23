# Souline Mobile

## Daftar nama anggota kelompok
- Adzradevany Aqiila - 2406410121
- Aghnaya Kenarantanov - 2406436410
- Cheryl Raynasya Adenan - 2406437571
- Cristian Dillon Philbert - 2406495956
- Muhammad Faza Al-Banna - 2406496082
- Farrel Rifqi Bagaskoro - 2406406780

## Tautan APK
WIP

## Deskripsi aplikasi
Nama “SOULINE” diambil dari kata “SOUL” yang artinya jiwa, dan “LINE” yang artinya garis. Dua kata ini relevan dengan olahraga Yoga & Pilates yang mementingkan ketenangan jiwa dan keseimbangan. Pengucapan “SOULINE” juga mirip dengan kata ‘SOLAINE” dalam bahasa Prancis yang dapat diartikan sebagai Brightness atau Positivity. Aplikasi ini akan membantu pengguna untuk mencari dan menentukan studio olahraga berdasarkan area yang mereka pilih. Pengguna juga dapat melihat rekomendasi sportswear dan resources dalam mempelajari Yoga & Pilates. Selain itu, pengguna dapat berbagi pengalaman dengan komunitas yang dapat meningkatkan semangat dalam berolahraga Yoga atau Pilates. 

## Daftar modul yang diimplementasikan beserta pembagian kerja per anggota
### Studio (Faza)
Modul yang digunakan untuk mencari studio terdekat di lingkup daerah Jabodetabek. Modul ini berisi detail studio yoga dan/atau pilates, termasuk data seperti nama studio, foto-foto di dalam studio, jam buka-tutup, rating dan reviews, serta link ke google maps. Modul ini juga memiliki fitur untuk melakukan booking sesuai dengan ketentuan dari studio masing masing, dapat melalui WhatsApp atau melalui link ke website langsung.

### Sportswear (Cheryl)
Modul yang berguna untuk mencari sportswear yang akan membantu olahraga yoga dan/atau pilates, seperti diantaranya yoga pants, yoga clothes, yoga mat, dan sebagainya. Di modul ini akan ditampilkan brand-brand yang populer. Setiap brand akan memiliki tombol yang akan mengarah langsung ke online shop seperti Tokopedia/Shopee (atau keduanya) yang nantinya akan berguna bagi user agar segera membeli sportswear yang diinginkan.

### Resources (Dillon)
Modul ini akan memberikan panduan untuk memulai olahraga yoga dan/atau pilates. Panduan akan dibagi dari tingkat kesulitannya, dari yang baru mulai melakukan yoga dan/atau pilates hingga yang sudah ahli. Di modul ini akan diberikan sebuah video YouTube (melalui embed) kemudian ada paragraf penjelasan juga bagi yang tidak ingin menonton videonya. Tiap langkah akan dijelaskan secara mendetail agar tidak ada kesalahan dalam melakukan kegiatan olahraga.

### User (profile) (Farrel)
Sebuah modul yang akan menyimpan informasi pengguna saat ini. Modul ini sudah termasuk halaman register, login, dan fitur log out di halaman utama. Semua modul dalam website Souline akan memerlukan login, setiap user diperlukan untuk membuat akun untuk membuka website. Akun dapat dibuat dengan registrasi username dan password, dengan validasi password yang aman menggunakan implementasi dari Django. User juga diminta untuk memasukkan kota tempat tinggal saat ini untuk mempersonalisasikan pengalaman website berdasarkan lokasi (terutama modul studio).

### Timeline (Lala)
Modul ini memungkinkan pengguna untuk membuat post dalam bentuk teks dan/atau gambar untuk berbagi pengalaman, tips, atau konten seputar yoga dan pilates. Pengguna juga dapat mengedit dan menghapus post miliknya sendiri. Setiap postingan akan muncul di timeline dan bisa dilihat oleh semua user (seperti Twitter atau Instagram feed).

### Events (Aghnaya)
Modul ini berguna untuk menginformasikan acara terkait olahraga yoga dan/atau pilates yang tersedia untuk diikuti. Modul akan menampilkan suatu timeline berisi acara-acara yang akan datang beserta tanggal dan lokasinya. Informasi yang akan ditampilkan untuk setiap acara adalah nama acara, deskripsi singkat, dan poster dari acara tersebut. Setiap event akan mempunyai gambar poster dan mekanisme pendaftarannya masing-masing, misalnya dengan mengisi link Google Forms atau registrasi secara offline. Informasi mengenai acara-acara ini kami dapatkan dari sosial media atau komunitas yang ada.

## Peran atau aktor pengguna aplikasi
### Role admin 
Admin dapat melakukan Create (membuat/menambahkan), Update (mengubah) dan Delete (menghapus) di setiap modul yang mengimplementasikan CRUD. Kedua fungsi tersebut ekslusif untuk Admin di modul Studio, Sportswear, Resources, dan Events.
### Role guest user
Guest user atau user yang tidak logged in dapat melakukan Read (membaca/mengakses) seluruh konten di aplikasi ini. Namun, guest tidak dapat melakukan Create (membuat) post di modul timeline. Studio akan ditampilkan dalam urutan acak di halaman utama dan sesuai urutan kota di halaman khusus Studio.
### Role logged in user
User yang sudah logged in dapat melihat kotanya sendiri sebagai preferensi di paling atas di halaman utama dan di halaman Studio. User juga dapat melakukan Create (membuat) post di modul timeline dan berinteraksi dengan post yang sudah ada, seperti memberikan komentar dan like.

## Penjelasan alur pengintegrasian data di aplikasi dengan aplikasi web (PWS) yang sudah dibuat saat Proyek Tengah Semester berbasis web service.
WIP

## Link Design Figma
https://www.figma.com/design/ql7AIQTcw69ICUzbf60xvR/souline?node-id=0-1&t=mGIfyTrPUYCfaMXp-1
