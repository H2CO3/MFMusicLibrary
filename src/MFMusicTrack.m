//
// MFMusicTrack.m
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

#import "MFMusicTrack.h"


@implementation MFMusicTrack

@synthesize path = path;
@synthesize title = title;
@synthesize album = album;
@synthesize artist = artist;
@synthesize genre = genre;
@synthesize year = year;
@synthesize comment = comment;
@synthesize composer = composer;
@synthesize category = category;
@synthesize artwork = artwork;
@synthesize rating = rating;
@synthesize mediatype = mediatype;
@synthesize length = length;

@end

