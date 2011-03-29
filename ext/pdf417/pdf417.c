/*  NOTE:  This relies on the PDF417 Library from http://sourceforge.net/projects/pdf417lib and is included here 
 *
*/

#include <ruby.h>
#include "pdf417lib.h"
#include "pdf417.h"

/*  Ruby interface definitions */


// The initialization method for this module
void Init_pdf417() {
  rb_cPdf417 = rb_define_class("PDF417", rb_cObject);
  rb_define_singleton_method(rb_cPdf417, "encode_text", rb_pdf417_encode_text, 1);
  rb_define_singleton_method(rb_cPdf417, "new", rb_pdf417_new, 1);
  rb_define_method(rb_cPdf417, "initialize", rb_pdf417_init, 1);
  rb_define_method(rb_cPdf417, "codewords", rb_pdf417_codewords, 0);
  rb_define_method(rb_cPdf417, "to_blob", rb_pdf417_to_blob, 0);
  rb_define_method(rb_cPdf417, "bit_columns", rb_pdf417_bitColumns, 0);
  rb_define_method(rb_cPdf417, "bit_length", rb_pdf417_lenBits, 0);
  rb_define_method(rb_cPdf417, "code_rows", rb_pdf417_codeRows, 0);
  rb_define_method(rb_cPdf417, "code_columns", rb_pdf417_codeColumns, 0);
  rb_define_method(rb_cPdf417, "codeword_length", rb_pdf417_lenCodewords, 0);
  rb_define_method(rb_cPdf417, "error_level", rb_pdf417_errorLevel, 0);
  rb_define_method(rb_cPdf417, "generation_options", rb_pdf417_options, 0);
  rb_define_method(rb_cPdf417, "aspect_ratio", rb_pdf417_aspectRatio, 0);
  rb_define_method(rb_cPdf417, "y_height", rb_pdf417_yHeight, 0);
  rb_define_method(rb_cPdf417, "generation_error", rb_pdf417_error, 0);  
}

// A class method to just get some codewords
extern VALUE rb_pdf417_encode_text(VALUE self, VALUE text) {
  VALUE list;
  int k;
  
  pdf417param p;
  pdf417init(&p);
  p.text = StringValuePtr(text);
  fetchCodewords(&p);
  if (p.error) {
      pdf417free(&p);
      return Qnil; //could also return list or raise something
  }
  
  list = rb_ary_new2(p.lenCodewords);
  
  pdf417free(&p); 
  
  for (k = 0; k < p.lenCodewords; ++k) {
    rb_ary_push(list, INT2NUM(p.codewords[k]));
  }
  return list;
}

static void rb_pdf417_cleanup(void *p) {
  pdf417free(p); 
}

static VALUE rb_pdf417_init(VALUE self, VALUE text) {
  rb_iv_set(self, "@text", text);
  return self;
}

static VALUE rb_pdf417_new(VALUE class, VALUE text) {
  VALUE argv[1];
  pdf417param *ptr;
  VALUE tdata = Data_Make_Struct(class, pdf417param, 0, rb_pdf417_cleanup, ptr);
  pdf417init(ptr);
  argv[0] = text;
  rb_obj_call_init(tdata, 1, argv);
  return tdata;
}

static VALUE rb_pdf417_codewords(VALUE self) {
  VALUE list;
  int k;
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  
  // Only re-do it if our text has changed
  if ( ptr->text != STR2CSTR(rb_iv_get(self, "@text")) ) {
    ptr->text = STR2CSTR(rb_iv_get(self, "@text")); //StringValuePtr(text); 

    paintCode(ptr); //paintCode also sets the error correction, we call it here so we can get the blob if needed w/o trouble
  }
  
  // otherwise, fill the array and respond
  if (ptr->error) {
      return Qnil; //could also return list
  }
  
  list = rb_ary_new2(ptr->lenCodewords);
  
  // The first codeword is the length of the data, which is all we're interested in here.
  for (k = 0; k < ptr->codewords[0]; ++k) {
    rb_ary_push(list, INT2NUM(ptr->codewords[k]));
  }
  return list;  
}

static VALUE rb_pdf417_to_blob(VALUE self) {
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  
  // Only re-do it if our text has changed
  if ( ptr->text != STR2CSTR(rb_iv_get(self, "@text")) ) {
    ptr->text = STR2CSTR(rb_iv_get(self, "@text")); //StringValuePtr(text); 

    paintCode(ptr);
  }
  
  // otherwise, fill the array and respond
  if (ptr->error) {
      return Qnil; //could also return list
  }
  
  return rb_str_new2(ptr->outBits);
}


static VALUE rb_pdf417_bitColumns(VALUE self) {
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  return INT2NUM(ptr->bitColumns);
}

static VALUE rb_pdf417_lenBits(VALUE self) {
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  return INT2NUM(ptr->lenBits);
}
static VALUE rb_pdf417_codeRows(VALUE self) {
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  return INT2NUM(ptr->codeRows);
}
static VALUE rb_pdf417_codeColumns(VALUE self) {
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  return INT2NUM(ptr->codeColumns);
}
static VALUE rb_pdf417_lenCodewords(VALUE self) {
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  return INT2NUM(ptr->lenCodewords);
}
static VALUE rb_pdf417_errorLevel(VALUE self){
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  return INT2NUM(ptr->errorLevel);
}
static VALUE rb_pdf417_options(VALUE self){
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  return INT2NUM(ptr->options);
}
static VALUE rb_pdf417_aspectRatio(VALUE self){
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  return rb_float_new(ptr->aspectRatio);
}
static VALUE rb_pdf417_yHeight(VALUE self){
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  return rb_float_new(ptr->yHeight);
}
static VALUE rb_pdf417_error(VALUE self){
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  return INT2NUM(ptr->error);
}
