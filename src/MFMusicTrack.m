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

+ (MFMusicTrack *) track {
	return [[[self alloc] init] autorelease];
}

+ (MFMusicTrack *) trackFromTag:(MFID3Tag *)tag {
	MFMusicTrack *track = [self track];
	track.title = [tag songTitle];
	track.album = [tag album];
	track.artist = [tag artist];
	track.genre = [tag genre];
	track.year = [tag year];
	track.comment = [tag comments];
	track.composer = [tag lyricist];
	track.artwork = [tag albumArtworkImageData];
	track.length = [tag length];
	track.mediatype = 32; // all types of media
	return track;
}

+ (MFMusicTrack *) trackFromGpodTrack:(Itdb_Track *)track {
	MFMusicTrack *mtrk = [self track];
       	gchar *path = itdb_filename_on_ipod(track);
       	if (path == NULL) {
       		// if a track is already present in the library, but
       		// it has no corresponding file in the filesystem,
       		// then something went wrong
       		return nil;
       	}
       	itdb_filename_ipod2fs(path);
       	gchar *title = track->title;
       	gchar *album = track->album;
       	gchar *artist = track->artist;
       	gchar *genre = track->genre;
       	guint32 year = track->year;
       	gchar *comment = track->comment;
	gchar *composer = track->composer;
	gchar *category = track->category;
	guint32 rating = track->rating;
	guint32 mediatype = track->mediatype;
	gint32 length = track->tracklen;
	mtrk.path = [NSString stringWithUTF8String: path];
	g_free(path);
	mtrk.title = title ? [NSString stringWithUTF8String: title] : MFLocalizedString(@"No title");
	mtrk.album = album ? [NSString stringWithUTF8String: album] : MFLocalizedString(@"Unknown album");
	mtrk.artist = artist ? [NSString stringWithUTF8String: artist] : MFLocalizedString(@"Unknown artist");
	mtrk.genre = genre ? [NSString stringWithUTF8String: genre] : MFLocalizedString(@"Unknown genre");
	mtrk.year = [NSString stringWithFormat:@"%d", year];
	mtrk.comment = comment ? [NSString stringWithUTF8String: comment] : @"";
	mtrk.composer = composer ? [NSString stringWithUTF8String: composer] : MFLocalizedString(@"Unknown composer");
	mtrk.category = category ? [NSString stringWithUTF8String: category] : MFLocalizedString(@"Unknown category");
	mtrk.length = length;
	mtrk.rating = rating;
	mtrk.mediatype = mediatype;
	// we can't simply get the artwork data from the track using libgpod
	// so we set it to NULL in order to
	// have it preserved when writing back it to the library without the user touching it
	// (the setter function checks for [artwork length] != 0 so it won't
	// delete the artwork image if our data is nil)
	mtrk.artwork = nil;
	return mtrk;
}

// libgpod-style track struct from an MFMusicTrack object
// g_malloc()'d -> should be g_free()'d after use
+ (Itdb_Track *) gpodTrackFromTrack:(MFMusicTrack *)track {
	Itdb_Track *trk = itdb_track_new();
	// and fill up with the needed info
	trk->title = (gchar *)[track.title UTF8String];
	trk->album = (gchar *)[track.album UTF8String];
	trk->artist = (gchar *)[track.artist UTF8String];
	trk->genre = (gchar *)[track.genre UTF8String];
	trk->year = (guint32)[track.year intValue];
	trk->comment = (gchar *)[track.comment UTF8String];
	trk->composer = (gchar *)[track.composer UTF8String];
	trk->category = (gchar *)[track.category UTF8String];
	trk->tracklen = (gint32)track.length;
	trk->rating = (guint32)track.rating;
	trk->mediatype = (guint32)track.mediatype;
	// add the album artwork data to the track
	// we assume rotation = 0° in order to get this
	// working without libexif.
	// we don't want an error to be set and we also igore the return value
	if ([track.artwork length] != 0) {
		const guchar *data_bytes = (const guchar *)[track.artwork bytes];
		gsize data_length = (gsize)[track.artwork length];
		itdb_artwork_set_thumbnail_from_data(trk->artwork, data_bytes, data_length, 0, NULL);
	}
	return trk;
}

@end

