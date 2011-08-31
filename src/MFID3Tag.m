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

- (id) initWithFileName: (NSString *) fileName {

	self = [super init];

	if ((fileName == nil) || ([fileName isEqualToString: @""])) {
		return nil;
	}

        // We need to write to the file
	file = id3_file_open ([fileName UTF8String], ID3_FILE_MODE_READWRITE);

	if (file == NULL) {
		return nil;
	}

	tag = id3_file_tag (file);

	if (tag == NULL) {
		return nil;
	}

	return self;

}

- (NSString *) frameDataForId: (char *) frameId {

        // find the first tag of id frameId
	struct id3_frame *frm = id3_tag_findframe (tag, frameId, 0);
	if (frm == NULL) {
		return nil;
	}

        // if no text in frame, return nil
	union id3_field *field = &frm->fields[1];
	int n = id3_field_getnstrings (field);
	if (n == 0) {
		return nil;
	}

        // else, get the first string
	const id3_ucs4_t *buf = id3_field_getstrings (field, 0);
        // and Cocoaize it
	NSString *val = [NSString stringWithUTF8String: (char *)id3_ucs4_utf8duplicate (buf)];

	return val;

}

- (BOOL) setFrameData: (NSString *) value forId: (char *) frameId {

        // One may not set data to nil
	if (value == nil) {
		return NO;
	}
	
        // get the frame for id frameId
	struct id3_frame *frm = id3_tag_findframe (tag, frameId, 0);
	
	BOOL frameIsNew = NO;
        // if not exists, create and append
	if (frm == NULL) {
		frm = id3_frame_new (frameId);
		frameIsNew = YES;
	}
        // if creation failed, we can't do anything else
	if (frm == NULL ) {
		return NO;
	}

	// convert to UCS4 because ID3
        // frames like this encoding
	id3_ucs4_t *ptr = id3_utf8_ucs4duplicate ((unsigned char *)[value UTF8String]);
        // set one string: The String
	if (id3_field_setstrings (&frm->fields[1], 1, &ptr) == -1) {
		return NO;
	}

        // if nonexistent, attach frame
	if (frameIsNew) {
		if (id3_tag_attachframe (tag, frm) == -1) {
			return NO;
		}
	}

        // and save the result to the file
	if (id3_file_update (file) == -1) {
		return NO;
	}
	
	return YES;

}

- (NSString *) songTitle {

	return [self frameDataForId: ID3_FRAME_TITLE];

}

- (BOOL) setSongTitle: (NSString *) data {

	return [self setFrameData: data forId: ID3_FRAME_TITLE];
	
}

- (NSString *) artist {

	return [self frameDataForId: ID3_FRAME_ARTIST];

}

- (BOOL) setArtist: (NSString *) data {

	return [self setFrameData: data forId: ID3_FRAME_ARTIST];
	
}

- (NSString *) album {

	return [self frameDataForId: ID3_FRAME_ALBUM];

}

- (BOOL) setAlbum: (NSString *) data {

	return [self setFrameData: data forId: ID3_FRAME_ALBUM];

}

- (NSString *) year {

	return [self frameDataForId: ID3_FRAME_YEAR];

}

- (BOOL) setYear: (NSString *) data {

	return [self setFrameData: data forId: ID3_FRAME_YEAR];
	
}

// this method has been completely rewritten using
// libid3tag's own genre map array and functions to be elegant
// this means that we no longer need those freaking plists
- (NSString *) genre {

	NSString *genre = nil;
	
	const char *genre_numstr = [[self frameDataForId: ID3_FRAME_GENRE] UTF8String];
	id3_ucs4_t *genre_numstr_ucs4 = id3_utf8_ucs4duplicate (genre_numstr);
	unsigned int genre_num = (unsigned int)id3_ucs4_getnumber (genre_numstr_ucs4);
	const id3_ucs4_t *genre_name_ucs4 = id3_genre_index (genre_num);
	const char *genre_name = id3_ucs4_utf8duplicate (genre_name_ucs4);
	
	if (genre_name != NULL) {
		genre = [NSString stringWithUTF8String: genre_name];
	}
	
	return genre;
	
}

// now we have to make sure the user entered
// a valid genre
// but libid3tag's functions can seamlessly do this for us
// it's even cool that libid3tag's implementation is not only
// case- but also encoding-insensitive
- (BOOL) setGenre: (NSString *) data {

	const char *genre = [data UTF8String];
	const id3_ucs4_t *genre_ucs4 = id3_utf8_ucs4duplicate (genre);
	int genre_num = id3_genre_number (genre_ucs4);

	if (genre_num < 0) {
		return NO;

	}
	NSString *genre_numstr = [NSString stringWithFormat: @"%i", genre_num];

	return [self setFrameData: genre_numstr forId: ID3_FRAME_GENRE];

}

- (NSString *) lyricist {

	return [self frameDataForId: "TEXT"];
	
}

- (BOOL) setLyricist: (NSString *) data {

	return [self setFrameData: data forId: "TEXT"];
	
}

- (NSString *) language {

	return [self frameDataForId: "TLAN"];
	
}

- (BOOL) setLanguage: (NSString *) data {

	return [self setFrameData: data forId: "TLAN"];
	
}

// the comments frame is not a normal text frame:
// it has its data in field #3, not field #1
// so we use the same code as in the primitives
// but with a changed frame index
- (NSString *) comments {

	struct id3_frame *frm = id3_tag_findframe (tag, ID3_FRAME_COMMENT, 0);
	if (frm == NULL) {
		return nil;
	}

	union id3_field *field = &frm->fields[3];

	const id3_ucs4_t *buf = id3_field_getfullstring (field);
	NSString *val = [NSString stringWithUTF8String: (char *)id3_ucs4_latin1duplicate (buf)];

	return val;
	
}

- (BOOL) setComments: (NSString *) data {

	if (data == nil) {
		return NO;
	}
	
	struct id3_frame *frm = id3_tag_findframe (tag, ID3_FRAME_COMMENT, 0);
	
	BOOL frameIsNew = NO;
	if (frm == NULL) {
		frm = id3_frame_new (ID3_FRAME_COMMENT);
		frameIsNew = YES;
	}
	if (frm == NULL ) {
		return NO;
	}
	
	id3_ucs4_t *ptr = id3_latin1_ucs4duplicate ((unsigned char *)[data UTF8String]);
	if (id3_field_setfullstring (&frm->fields[3], ptr) == -1) {
		return NO;
	}

	if (frameIsNew) {
		if (id3_tag_attachframe (tag, frm) == -1) {
			return NO;
		}
	}

	if (id3_file_update (file) == -1) {
		return NO;
	}
	
	return YES;

}

// APIC is not a text frame
// so we use id3_field_getbinarydata
// (and field index #4)
- (NSData *) albumArtworkImageData {

	struct id3_frame *frm = id3_tag_findframe (tag, "APIC", 0);
	if (frm == NULL) {
		return nil;
	}

	union id3_field *field = &frm->fields[4];

	id3_length_t length;
	const id3_byte_t *buf = id3_field_getbinarydata (field, &length);

	NSData *imageData = [NSData dataWithBytes: buf length: length];

	return imageData;

}

- (BOOL) setAlbumArtworkImageData: (NSData *) data {

	if ((data == nil) || ([data length] == 0)) {
		return NO;
	}
	
	struct id3_frame *frm = id3_tag_findframe (tag, "APIC", 0);
	
	BOOL frameIsNew = NO;
	if (frm == NULL) {
		frm = id3_frame_new ("APIC");
		frameIsNew = YES;
	}
	if (frm == NULL ) {
		return NO;
	}
	
	const id3_byte_t *ptr = [data bytes];
	id3_length_t length = [data length];
	if (id3_field_setbinarydata (&frm->fields[4], ptr, length) == -1) {
		return NO;
	}

	if (frameIsNew) {
		if (id3_tag_attachframe (tag, frm) == -1) {
			return NO;
		}
	}

	if (id3_file_update (file) == -1) {
		return NO;
	}
	
	return YES;

}

- (uint32_t) length {

	return (uint32_t)[[self frameDataForId: "TLAN"] longLongValue];
	
}

- (BOOL) setLength: (uint32_t) length {

	NSString *textLength = [[NSString alloc] initWithFormat: @"%ld", length];
	BOOL result = [self setFrameData: textLength forId: "TLAN"];
	[textLength release];
	
	return result;
	
}

// super

- (void) dealloc {

	id3_file_close (file);

	[super dealloc];

}

@end
