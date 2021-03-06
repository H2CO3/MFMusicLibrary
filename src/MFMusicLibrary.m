//
// MFMusicLibrary.m
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

#import "MFMusicLibrary.h"

static MFMusicLibrary *sharedInstance = nil;


@implementation MFMusicLibrary

// class methods

// If nonexistent, create the static shared instance and return it
+ (id) sharedLibrary {
	if (sharedInstance == nil) {
		sharedInstance = [[self alloc] init];
	}
	return sharedInstance;
}

// super

// The designated initializer
- (id) init {
	self = [super init];
	// we don't want an error to be returned
	itdb = itdb_parse(MFDeviceMediaDirectory, NULL);
	if (itdb == NULL) {
		// if for some reason, parsing failed, return nil
		[self release];
		return nil;
	}
	return self;
}

// self

- (BOOL) write {
	// we don't want an error to be returned
	BOOL success = itdb_write(itdb, NULL);
	if (!success) {
		// something went wrong
		return NO;
	}
	// if the write process succeeded,
	// there were (potentially and likely)
	// changes in the contents of the library,
	// so we'll need to reload its contents
	[self refreshContents];
	return YES;
}

- (void) refreshContents {
	// no need to release the database
	// (releasing causes a segfault)
	// also no need to check if the parsing succeeded,
	// because if it fails it has already failed once,
	// so self is already nil thus no message sends
	// will have any effects
	itdb = itdb_parse(MFDeviceMediaDirectory, NULL);
}

- (uint32_t) numberOfPlaylists {
	uint32_t num = itdb_playlists_number(itdb);
	return num;
}

- (NSString *) playlistNameForIndex:(uint32_t)index {
	Itdb_Playlist *playlist = itdb_playlist_by_nr(itdb, index);
	NSString *name = [NSString stringWithUTF8String:playlist->name];
	return name;
}

- (void) createPlaylistWithName:(NSString *)name {
	gchar *nm = (gchar *)[name UTF8String];
	// NO: we don't want a smart playlist
	Itdb_Playlist *playlist = itdb_playlist_new(nm, false);
	// No. = -1 means "add last"
	itdb_playlist_add(itdb, playlist, -1);
}

- (void) removePlaylistWithName:(NSString *)name {
	gchar *nm = (gchar *)[name UTF8String];
	Itdb_Playlist *playlist = itdb_playlist_by_name(itdb, nm);
	itdb_playlist_remove(playlist);
}

- (uint32_t) numberOfTracks {
	uint32_t num = itdb_tracks_number(itdb);
	return num;
}

- (MFMusicTrack *) trackForIndex:(uint32_t)index {
	Itdb_Playlist *playlist = itdb_playlist_mpl(itdb);
       	Itdb_Track *track = g_list_nth_data(playlist->members, index);
	MFMusicTrack *mtrk = [MFMusicTrack trackFromGpodTrack:track];
	return mtrk;
}

- (void) removeTrackForIndex:(uint32_t)index {
	Itdb_Playlist *pl;
	uint32_t num = itdb_playlists_number(itdb);
	// get the master playlist
	Itdb_Playlist *mpl = itdb_playlist_mpl(itdb);
	// and the indexth track
	Itdb_Track *track = g_list_nth_data(mpl->members, index);
	// iterate over all playlists and
	// let them remove the track if exists
	for (uint32_t i = 0; i < num; i++) {
		pl = itdb_playlist_by_nr(itdb, i);
		itdb_playlist_remove_track(pl, track);
	}
	// and delete the track from the itdb itself
	itdb_track_remove(track);
}

- (uint32_t) numberOfTracksInPlaylist:(NSString *)name {
	gchar *nm = (gchar *)[name UTF8String];
	Itdb_Playlist *playlist = itdb_playlist_by_name(itdb, nm);
	uint32_t num = itdb_playlist_tracks_number(playlist);
	return num;
}

- (MFMusicTrack *) trackForIndex:(uint32_t)index inPlaylist:(NSString *)name {
	// find the playlist by name
	gchar *nm = (gchar *)[name UTF8String];
	Itdb_Playlist *playlist = itdb_playlist_by_name(itdb, nm);
	// get the indexth track in the playlist
       	Itdb_Track *track = g_list_nth_data(playlist->members, index);
       	MFMusicTrack *mtrk = [MFMusicTrack trackFromGpodTrack:track];
 	return mtrk;
}

- (void) removeTrackForIndex:(uint32_t)index fromPlaylist:(NSString *)name {
	// find the playlist by name
	gchar *nm = (gchar *)[name UTF8String];
	Itdb_Playlist *playlist = itdb_playlist_by_name(itdb, nm);
	// get the indexth track in the playlist
       	Itdb_Track *track = g_list_nth_data(playlist->members, index);
	// now remove it
	itdb_playlist_remove_track(playlist, track);
}

- (BOOL) addFile:(NSString *)path {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	// set the properties of the track from ID3 info
	MFID3Tag *tag = [[MFID3Tag alloc] initWithFileName:path];
	MFMusicTrack *track = [MFMusicTrack trackFromTag:tag];
	[tag release];
	// add the track to the library
	BOOL success = [self addFile:path asTrack:track];
	[pool release];
	return success;
}

- (BOOL) addFile:(NSString *)path asTrack:(MFMusicTrack *)track {
	const char *p = [path UTF8String];
	// find the master playlist
	Itdb_Playlist *mpl = itdb_playlist_mpl(itdb);
	// create a new libgpod track object
	Itdb_Track *trk = [MFMusicTrack gpodTrackFromTrack:track];
	// add track to both the database and master playlist as last
	itdb_track_add(itdb, trk, -1);
	itdb_playlist_add_track(mpl, trk, -1);
	// (since the iTunesDB manages the memory for the track, we don't need to g_free() it)
	// and actually copy the file to the iPod library
	// NULL: we don't want any errors to be returned
	BOOL success = itdb_cp_track_to_ipod(trk, p, NULL);
	return success;
}

- (BOOL) addFile:(NSString *)path toPlaylist:(NSString *)name {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	MFID3Tag *tag = [[MFID3Tag alloc] initWithFileName:path];
	MFMusicTrack *track = [MFMusicTrack trackFromTag:tag];
	[tag release];
	BOOL success = [self addFile:path asTrack:track toPlaylist:name];
	[pool release];
	return success;
}

- (BOOL) addFile:(NSString *)path asTrack:(MFMusicTrack *)track toPlaylist:(NSString *)name {
	const char *p = [path UTF8String];
	// find the master playlist
	Itdb_Playlist *mpl = itdb_playlist_mpl(itdb);
	// find the specified playlist
	gchar *nm = (gchar *)[name UTF8String];
	Itdb_Playlist *playlist = itdb_playlist_by_name(itdb, nm);
	// create a new libgpod track object
	Itdb_Track *trk = [MFMusicTrack gpodTrackFromTrack:track];
	// add track to: the library, the specified and the master playlist
	// (-1: as last item)
	// again: the Itdb_iTunesDB takes care of the memory
	itdb_track_add(itdb, trk, -1);
	itdb_playlist_add_track(playlist, trk, -1);
	itdb_playlist_add_track(mpl, trk, -1);
	// and actually copy the file to the iPod library
	// NULL: we don't want any errors to be returned
	BOOL success = itdb_cp_track_to_ipod(trk, p, NULL);
	return success;
}

@end

