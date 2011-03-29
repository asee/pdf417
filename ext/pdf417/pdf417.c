/*  NOTE:  This relies on the PDF417 Library from http://sourceforge.net/projects/pdf417lib and is included here 
 *
*/

#include <ruby.h>
#include "pdf417lib.h"
#include "pdf417.h"

/*  A wrapper for the pdf417lib C Library, from the README:

      A library to generate the 2D barcode PDF417

      Project: http://sourceforge.net/projects/pdf417.lib
      Creator: Paulo Soares (psoares@consiste.pt)
      License: LGPL or MPL 1.1

      This library generates a PDF417 image of the barcode in a 1x1 scale.
      It requires that the displayed image be as least stretched 3 times
      in the vertical direction in relation with the horizontal dimension.
   
   This class will interface with the C library to take a text string representing
   the barcode data and produce a list of data codewords, or a binary string (blob)
   representing a bitmap.

 */


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

/*
 * call-seq:
 *   encode_text(text)
 *
 * Returns an array of integers showing the codewords
 */
static VALUE rb_pdf417_encode_text(VALUE self, VALUE text) {
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

/* :nodoc: */
static void rb_pdf417_cleanup(void *p) {
  pdf417free(p); 
}

/* :nodoc: */
static VALUE rb_pdf417_init(VALUE self, VALUE text) {
  rb_iv_set(self, "@text", text);
  return self;
}

/*
 * call-seq:
 *  new(text)
 *
 * Makes a new PDF417 object for the given text string
 */
static VALUE rb_pdf417_new(VALUE class, VALUE text) {
  VALUE argv[1];
  pdf417param *ptr;
  VALUE tdata = Data_Make_Struct(class, pdf417param, 0, rb_pdf417_cleanup, ptr);
  pdf417init(ptr);
  argv[0] = text;
  rb_obj_call_init(tdata, 1, argv);
  return tdata;
}

/*
 * call-seq:
 *  codewords
 *
 * Generates an array of codewords from the current text attribute
 */
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

/*
 * call-seq:
 *  to_blob
 *
 * Returns a binary string representing the image bits, requires scaling before display
 */
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

/*
 * call-seq:
 *  bit_columns
 *
 * The number of column bits in the bitmap
 */
static VALUE rb_pdf417_bitColumns(VALUE self) {
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  return INT2NUM(ptr->bitColumns);
}

/*
 * call-seq:
 *  bit_length
 *
 * The size in bytes of the bitmap
 */
static VALUE rb_pdf417_lenBits(VALUE self) {
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  return INT2NUM(ptr->lenBits);
}

/*
 * call-seq:
 *  code_rows
 *
 * The number of code rows and bitmap lines
 */
static VALUE rb_pdf417_codeRows(VALUE self) {
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  return INT2NUM(ptr->codeRows);
}

/*
 * call-seq:
 *  code_columns
 *
 * The number of code columns
 */
static VALUE rb_pdf417_codeColumns(VALUE self) {
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  return INT2NUM(ptr->codeColumns);
}

/*
 * call-seq:
 *  codeword_length
 *
 * The size of the code words, including error correction codes
 */
static VALUE rb_pdf417_lenCodewords(VALUE self) {
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  return INT2NUM(ptr->lenCodewords);
}

/*
 * call-seq:
 *  error_level
 *
 * The error level required 0-8
 */
static VALUE rb_pdf417_errorLevel(VALUE self){
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  return INT2NUM(ptr->errorLevel);
}

/*
 * call-seq:
 *  generation_options
 *
 * The int representing the options used to generate the barcode, defined in the library as:
 * [PDF417_USE_ASPECT_RATIO] use aspectRatio to set the y/x dimension. Also uses yHeight
 * [PDF417_FIXED_RECTANGLE] make the barcode dimensions at least codeColumns by codeRows
 * [PDF417_FIXED_COLUMNS] make the barcode dimensions at least codeColumns
 * [PDF417_FIXED_ROWS] make the barcode dimensions at least codeRows
 * [PDF417_AUTO_ERROR_LEVEL] automatic error level depending on text size
 * [PDF417_USE_ERROR_LEVEL] the error level is errorLevel. The used errorLevel may be different
 * [PDF417_USE_RAW_CODEWORDS] use codewords instead of text
 * [PDF417_INVERT_BITMAP] invert the resulting bitmap
 */
static VALUE rb_pdf417_options(VALUE self){
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  return INT2NUM(ptr->options);
}

/*
 * call-seq:
 *  aspect_ratio
 *
 * The y/x aspect ratio
 */
static VALUE rb_pdf417_aspectRatio(VALUE self){
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  return rb_float_new(ptr->aspectRatio);
}

/*
 * call-seq:
 *  y_height
 *
 * The y/x dot ratio
 */
static VALUE rb_pdf417_yHeight(VALUE self){
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  return rb_float_new(ptr->yHeight);
}

/*
 * call-seq:
 *  generation_error
 *
 * The error returned as an int, defined in C as:
 * [PDF417_ERROR_SUCCESS] no errors
 * [PDF417_ERROR_TEXT_TOO_BIG] the text was too big the PDF417 specifications
 * [PDF417_ERROR_INVALID_PARAMS] invalid parameters. Only used with PDF417_USE_RAW_CODEWORDS
 */
static VALUE rb_pdf417_error(VALUE self){
  pdf417param *ptr;
  Data_Get_Struct(self, pdf417param, ptr);
  return INT2NUM(ptr->error);
}
