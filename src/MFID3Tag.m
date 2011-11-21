//
// MFID3Tag.h
// MFMusicLibrary
// Originally written for MyFile
//
// Written by Árpád Goretity (H2CO3), 8 august 2011.
//
// MFMusicLibrary is licensed under a Creative Commons Attribution-NonCommercial 3.0 Unported License.
// As attribution, I just require that you mention my name in conjunction
// with this library, and that your application can reproduce this legal notice.
// For details, see: http://creativecommons.org/licenses/
//
// Although this library was written in the hope that it will be useful,
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR 'AS IS', THUS
// THERE IS NO WARRANTY AT ALL, NEITHER EXPRESSED OR IMPLIED, NOT EVEN
// FOR MERCHANTABILITY OR FITTNESS FOR A PARTICUALR PURPOSE. I (THE AUTHOR) AM NOT RESPONSIBLE
// FOR ANY DAMAGE, DATA LOSS OR ANY OTHER TYPES OF UNEXPECTED AND/OR BAD RESULTS
// IN CONNECTION OF THIS SOFTWARE.
//

// The library requires libgpod to be installed,
// which generates the following dependencies:
// libc (lame), Glib 2, libplist, gettext, libxml2, libsqlite3 and libz
// For reading MP3 metadata (ID3 tags), libid3tag also needs to be present

#import "MFID3Tag.h"


@implementation MFID3Tag

// self

- (id) initWithFileName:(NSString *)fileName {
	self = [super init];
	if ((fileName == nil) || ([fileName isEqualToString:@""])) {
		[self release];
		return nil;
	}
	// We need to write to the file
	file = id3_file_open([fileName UTF8String], ID3_FILE_MODE_READWRITE);
	if (file == NULL) {
		[self release];
		return nil;
	}
	tag = id3_file_tag(file);
	if (tag == NULL) {
		[self release];
		return nil;
	}
	return self;
}

- (NSString *) frameDataForId:(const char *)frameId {
	// find the first tag of id frameId
	struct id3_frame *frm = id3_tag_findframe(tag, frameId, 0);
	if (frm == NULL) {
		return nil;
	}
	// find the 2nd (#1) field of the frame
	// (this is the actual text data,
	// the 1st one (#0) contains the data type (string in this case))
	union id3_field *field = id3_frame_field(frm, 1);
	if (field == NULL) {
		return NO;
	}
	// if no text in frame, return nil
	int n = id3_field_getnstrings(field);
	if (n == 0) {
		return nil;
	}
	// else, get the first string
	const id3_ucs4_t *buf = id3_field_getstrings(field, 0);
	if (buf == NULL) {
		return nil;
	}
	// and Cocoaize it
	char *string_val = id3_ucs4_utf8duplicate(buf);
	if (string_val == NULL) {
		return nil;
	}
	NSString *val = [NSString stringWithUTF8String:string_val];
	free (string_val);
	return val;
}

- (BOOL) setFrameData:(NSString *)value forId:(const char *)frameId {
	// One may not set data to nil
	if (value == nil) {
		return NO;
	}
	// get the frame for id frameId
	struct id3_frame *frm = id3_tag_findframe(tag, frameId, 0);
	BOOL frameIsNew = NO;
	// if not exists, create and append
	if (frm == NULL) {
		frm = id3_frame_new(frameId);
		frameIsNew = YES;
	}
	// if creation failed, we can't do anything else
	if (frm == NULL ) {
		return NO;
	}
	// find the 2nd (#1) field of the frame
	// (this is the actual text data,
	// the 1st one (#0) contains the data type (string in this case))
	union id3_field *field = id3_frame_field(frm, 1);
	if (field == NULL) {
		return NO;
	}
	// convert to UCS4 because ID3
	// frames like this encoding
	id3_ucs4_t *ptr = id3_utf8_ucs4duplicate((char *)[value UTF8String]);
	// set one string: The String
	int success = id3_field_setstrings(field, 1, &ptr);
	free(ptr);
	if (success == -1) {
		return NO;
	}
	// if nonexistent, attach frame
	if (frameIsNew) {
		if (id3_tag_attachframe(tag, frm) == -1) {
			return NO;
		}
	}
	// and save the result to the file
	if (id3_file_update(file) == -1) {
		return NO;
	}
	return YES;
}

- (NSString *) songTitle {
	return [self frameDataForId:ID3_FRAME_TITLE];
}

- (BOOL) setSongTitle:(NSString *)data {
	return [self setFrameData:data forId:ID3_FRAME_TITLE];
}

- (NSString *) artist {
	return [self frameDataForId:ID3_FRAME_ARTIST];
}

- (BOOL) setArtist:(NSString *)data {
	return [self setFrameData:data forId:ID3_FRAME_ARTIST];
}

- (NSString *) album {
	return [self frameDataForId:ID3_FRAME_ALBUM];
}

- (BOOL) setAlbum:(NSString *)data {
	return [self setFrameData:data forId:ID3_FRAME_ALBUM];
}

- (NSString *) year {
	return [self frameDataForId:ID3_FRAME_YEAR];
}

- (BOOL) setYear:(NSString *)data {
	return [self setFrameData:data forId:ID3_FRAME_YEAR];
}

// this method has been completely rewritten using
// libid3tag's own genre map array and functions to be elegant
// this means that we no longer need those freaking plists
- (NSString *) genre {
	NSString *genre = nil;
	const char *genre_numstr = [[self frameDataForId:ID3_FRAME_GENRE] UTF8String];
	if (genre_numstr == NULL) {
		return genre;
	}
	id3_ucs4_t *genre_numstr_ucs4 = id3_utf8_ucs4duplicate((unsigned char *)genre_numstr);
	if (genre_numstr_ucs4 == NULL) {
		return genre;
	}
	unsigned int genre_num = (unsigned int)id3_ucs4_getnumber(genre_numstr_ucs4);
	free(genre_numstr_ucs4);
	const id3_ucs4_t *genre_name_ucs4 = id3_genre_index(genre_num);
	if (genre_name_ucs4 == NULL) {
		return genre;
	}
	char *genre_name = id3_ucs4_utf8duplicate(genre_name_ucs4);
	if (genre_name == NULL) {
		return genre;
	}
	genre = [NSString stringWithUTF8String:genre_name];
	free(genre_name);
	return genre;
}

// now we have to make sure the user entered
// a valid genre
// but libid3tag's functions can seamlessly do this for us
// it's even cool that libid3tag's implementation is not only
// case- but also encoding-insensitive
- (BOOL) setGenre:(NSString *)data {
	if ([data length] == 0) {
		return NO;
	}
	const char *genre = [data UTF8String];
	id3_ucs4_t *genre_ucs4 = id3_utf8_ucs4duplicate((unsigned char *)genre);
	if (genre_ucs4 == NULL) {
		return NO;
	}
	int genre_num = id3_genre_number(genre_ucs4);
	free(genre_ucs4);
	if (genre_num < 0) {
		return NO;

	}
	NSString *genre_numstr = [NSString stringWithFormat:@"%d", genre_num];
	return [self setFrameData:genre_numstr forId:ID3_FRAME_GENRE];
}

- (NSString *) lyricist {
	return [self frameDataForId:"TEXT"];
}

- (BOOL) setLyricist:(NSString *)data {
	return [self setFrameData:data forId:"TEXT"];
}

- (NSString *) language {
	return [self frameDataForId:"TLAN"];
}

- (BOOL) setLanguage:(NSString *)data {
	return [self setFrameData:data forId:"TLAN"];
}

// the comments frame is not a normal text frame:
// it has its data in field #3, not field #1
// so we use the same code as in the primitives
// but with a changed frame index
- (NSString *) comments {
	struct id3_frame *frm = id3_tag_findframe(tag, ID3_FRAME_COMMENT, 0);
	if (frm == NULL) {
		return nil;
	}
	union id3_field *field = id3_frame_field(frm, 3);
	if (field == NULL) {
		return nil;
	}
	const id3_ucs4_t *buf = id3_field_getfullstring(field);
	if (buf == NULL) {
		return nil;
	}
	char *comment = id3_ucs4_utf8duplicate((unsigned char *)buf);
	if (comment == NULL) {
		return nil;
	}
	NSString *val = [NSString stringWithUTF8String:comment];
	free(comment);
	return val;
}

- (BOOL) setComments:(NSString *)data {
	if ([data length] == 0) {
		return NO;
	}
	struct id3_frame *frm = id3_tag_findframe(tag, ID3_FRAME_COMMENT, 0);
	BOOL frameIsNew = NO;
	if (frm == NULL) {
		frm = id3_frame_new(ID3_FRAME_COMMENT);
		frameIsNew = YES;
	}
	if (frm == NULL ) {
		return NO;
	}
	id3_ucs4_t *ptr = id3_latin1_ucs4duplicate((unsigned char *)[data UTF8String]);
	if (ptr == NULL) {
		return NO;
	}
	union id3_field *field = id3_frame_field(frm, 3);
	if (field == NULL) {
		return NO;
	}
	int success = id3_field_setfullstring(field, ptr);
	free(ptr);
	if (success == -1) {
		return NO;
	}
	if (frameIsNew) {
		if (id3_tag_attachframe(tag, frm) == -1) {
			return NO;
		}
	}
	if (id3_file_update(file) == -1) {
		return NO;
	}
	return YES;

}

// APIC is not a text frame
// so we use id3_field_getbinarydata
// (and field index #4)
- (NSData *) albumArtworkImageData {
	struct id3_frame *frm = id3_tag_findframe(tag, "APIC", 0);
	if (frm == NULL) {
		return nil;
	}
	union id3_field *field = id3_frame_field(frm, 4);
	id3_length_t length = 0;
	const id3_byte_t *buf = id3_field_getbinarydata(field, &length);
	NSData *imageData = [NSData dataWithBytes:buf length:length];
	return imageData;
}

- (BOOL) setAlbumArtworkImageData:(NSData *)data {
	if ((data == nil) || ([data length] == 0)) {
		return NO;
	}
	struct id3_frame *frm = id3_tag_findframe(tag, "APIC", 0);
	BOOL frameIsNew = NO;
	if (frm == NULL) {
		frm = id3_frame_new("APIC");
		frameIsNew = YES;
	}
	if (frm == NULL ) {
		return NO;
	}
	union id3_field *field = id3_frame_field(frm, 4);
	if (field == NULL) {
		return NO;
	}
	const id3_byte_t *ptr = [data bytes];
	id3_length_t length = [data length];
	if (id3_field_setbinarydata(field, ptr, length) == -1) {
		return NO;
	}
	if (frameIsNew) {
		if (id3_tag_attachframe(tag, frm) == -1) {
			return NO;
		}
	}
	if (id3_file_update(file) == -1) {
		return NO;
	}
	return YES;
}

- (uint32_t) length {
	return (uint32_t)[[self frameDataForId:"TLEN"] longLongValue];
}

- (BOOL) setLength:(uint32_t)length {
	NSString *textLength = [[NSString alloc] initWithFormat:@"%d", length];
	BOOL result = [self setFrameData:textLength forId:"TLEN"];
	[textLength release];
	return result;
}

// super

- (void) dealloc {
	if (file != NULL) {
		id3_file_close (file);
	}
	[super dealloc];
}

@end

