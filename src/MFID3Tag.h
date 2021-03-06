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

#import <stdlib.h>
#import <sys/types.h>
#import <unistd.h>
#import <stdio.h>
#import <id3tag.h>
#import <Foundation/Foundation.h>
#import "MFCommonDefines.h"

// Abstraction class representing
// metadata in an MP3 audio file


@interface MFID3Tag: NSObject {
	struct id3_file *file;
	struct id3_tag *tag;
}

// the designated initializer
- (id) initWithFileName:(NSString *)fileName;

// primitives for accessing data in _TEXT_ frames.
// May not be needed to call directly
- (NSString *) frameDataForId:(const char *)frameId;
- (BOOL) setFrameData:(NSString *)value forId:(const char *)frameId;

// Accessors
// Note that setting a property immediately
// causes the data to be written to the file
- (NSString *) songTitle;
- (BOOL) setSongTitle:(NSString *)aSongTitle;
- (NSString *) artist;
- (BOOL) setArtist:(NSString *)anArtist;
- (NSString *) album;
- (BOOL) setAlbum:(NSString *)anAlbum;
- (NSString *) year;
- (BOOL) setYear:(NSString *)aYear;
- (NSString *) genre;
- (BOOL) setGenre:(NSString *)aGenre;
- (NSString *) lyricist;
- (BOOL) setLyricist:(NSString *)aLyricist;
- (NSString *) language;
- (BOOL) setLanguage:(NSString *)aLanguage;
- (NSString *) comments;
- (BOOL) setComments:(NSString *)aComment;
- (NSData *) albumArtworkImageData;
- (BOOL) setAlbumArtworkImageData:(NSData *)data;
- (uint32_t) length;
- (BOOL) setLength:(uint32_t)length;

@end

