List<int> bigEndianPutInt(int v) {
  // early bounds check to guarantee safety of writes below
  List<int> b = List.filled(8, 0);
  b[0] = (v >> 56) % 256;
  b[1] = (v >> 48) % 256;
  b[2] = (v >> 40) % 256;
  b[3] = (v >> 32) % 256;
  b[4] = (v >> 24) % 256;
  b[5] = (v >> 16) % 256;
  b[6] = (v >> 8) % 256;
  b[7] = (v % 256);
  return b;
}

int bigEndianInt(List<int> b) {
  b[7]; // bounds check hint to compiler; see golang.org/issue/14808
  return (b[7]) |
      (b[6]) << 8 |
      (b[5]) << 16 |
      (b[4]) << 24 |
      (b[3]) << 32 |
      (b[2]) << 40 |
      (b[1]) << 48 |
      (b[0]) << 56;
}
// func (bigEndian) Uint32(b []byte) uint32 {
// _ = b[3] // bounds check hint to compiler; see golang.org/issue/14808
// return uint32(b[3]) | uint32(b[2])<<8 | uint32(b[1])<<16 | uint32(b[0])<<24
// }

int bigEndianUInt32(List<int> b) {
  b[3]; // bounds check hint to compiler; see golang.org/issue/14808
  return (
  (b[3])   |
  (b[2]) << 8 |
  (b[1]) << 16 |
  (b[0]) << 24);
}