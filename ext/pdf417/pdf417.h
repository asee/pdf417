// strfunctions from Nokogiri
#define PDF417_STR_NEW2(str) \
  rb_str_new2((const char *)(str))

#define PDF417_STR_NEW(str, len) \
  rb_str_new((const char *)(str), (long)(len))

#define RBSTR_OR_QNIL(_str) \
  (_str ? PDF417_STR_NEW2(_str) : Qnil)

VALUE rb_cPdf417;
extern VALUE rb_pdf417_encode_text(VALUE self, VALUE text);
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
static VALUE rb_pdf417_options(VALUE self);
static VALUE rb_pdf417_aspectRatio(VALUE self);
static VALUE rb_pdf417_yHeight(VALUE self);
static VALUE rb_pdf417_error(VALUE self);
