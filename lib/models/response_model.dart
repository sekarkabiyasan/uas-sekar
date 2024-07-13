class Response {
  Object? data;
  String? message;
  String? error;
}

const timeoutException = 'Request timeout - Cek koneksi internet Anda';
const socketException = 'Gagal terhubung ke server - Cek koneksi internet Anda';
const serverError = 'Koneksi terputus, mohon coba lagi';
const somethingWentWrong = 'Koneksi terputus, mohon coba lagi';
