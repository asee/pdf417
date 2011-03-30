
VALUE rb_cPdf417;
static VALUE rb_pdf417_encode_text(VALUE self, VALUE text);
static VALUE rb_pdf417_codewords(VALUE self);
static VALUE rb_pdf417_to_blob(VALUE self);
static VALUE rb_pdf417_new(VALUE class, VALUE text);
static void rb_pdf417_cleanup(void *p);
static VALUE rb_pdf417_init(VALUE self, VALUE text);
static VALUE rb_pdf417_bitColumns(VALUE self);
static VALUE rb_pdf417_lenBits(VALUE self);
static VALUE rb_pdf417_codeRows(VALUE self);
static VALUE rb_pdf417_codeColumns(VALUE self);
static VALUE rb_pdf417_lenCodewords(VALUE self);
static VALUE rb_pdf417_errorLevel(VALUE self);
static VALUE rb_pdf417_aspectRatio(VALUE self);
static VALUE rb_pdf417_yHeight(VALUE self);
static VALUE rb_pdf417_error(VALUE self);
static void refreshStruct(VALUE self, pdf417param *ptr);