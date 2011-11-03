//
// MFMusicTrack.h
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
#import <gpod/itdb.h>
#import <Foundation/Foundation.h>
#import "MFCommonDefines.h"
#import "MFID3Tag.h"

// Class for representing media items in the iPod library
// Create instances using +alloc and -init
// Configure the allocated object by setting its properties
// Instances of MFMusicTrack are generally considered as temporary.
// After finishing a specific operation, deallocate them;
// the library uses other data structures for its internal logic.


@interface MFMusicTrack: NSObject {
	NSString *path;
	NSString *title;
	NSString *album;
	NSString *artist;
	NSString *genre;
	NSString *year;
	NSString *comment;
	NSString *composer;
	NSString *category;
	NSData *artwork;
	uint32_t rating;
	uint32_t mediatype;
	uint32_t length;
}

// this property is only valid when the object is returned by the library
// otherwise invalid and should be ignored
// if valid, use it to play a song at the given file path
@property (nonatomic, copy) NSString *path;
// these really belong to the song
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *album;
@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSString *genre;
@property (nonatomic, retain) NSString *year;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic, retain) NSString *composer;
// for podcasts, it indicates the category from where the
// podcast was retrieved
@property (nonatomic, retain) NSString *category;
// the image data containing album artwork data for the track
@property (nonatomic, retain) NSData *artwork;
// rating: an integer between 0...100
// 20 = *; 100 = *****
@property (nonatomic, assign) uint32_t rating;
// a bit mask representing the media type,
// see the Itdb_Mediatype enum
@property (nonatomic, assign) uint32_t mediatype;
// length of the track in milliseconds
@property (nonatomic, assign) uint32_t length;

// a generic, autoroeleased track object
+ (MFMusicTrack *) track;
// create a track from a file's ID3 tag data
+ (MFMusicTrack *) trackFromTag:(MFID3Tag *)tag;
// create a track from libgpod's structs
+ (MFMusicTrack *) trackFromGpodTrack:(Itdb_Track *)track;
// create a libgpod track object from an MFMusicTrack instance
+ (Itdb_Track *) gpodTrackFromTrack:(MFMusicTrack *)track;

@end

