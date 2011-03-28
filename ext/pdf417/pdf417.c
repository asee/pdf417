#include <ruby.h>
#include "pdf417lib.h"
#include "pdf417.h"

/*  Ruby interface definitions */


// Defining a space for information and references about the module to be stored internally
VALUE rb_cPdf417 = Qnil;


// The initialization method for this module
void Init_pdf417() {
  rb_cPdf417 = rb_define_class("PDF417", rb_cObject);
  rb_define_singleton_method(rb_cPdf417, "encode_text", rb_pdf417_encode_text, 1);
}

static VALUE rb_pdf417_encode_text(VALUE self, VALUE content) {
  VALUE list;
  int k;
  
  pdf417param p;
  pdf417init(&p);
  p.text = StringValuePtr(content);
  //p.options = ....; // In case we get fancy
  fetchCodewords(&p);
  if (p.error) {
      // do something about the error?
      pdf417free(&p);
      return Qnil; //could also return list
  }
  
  list = rb_ary_new();
  
  pdf417free(&p); 
  
  for (k = 0; k < p.lenCodewords; ++k) {
    rb_ary_push(list, INT2NUM(p.codewords[k]));
  }
  return list;
}
