//
// MFMusicLibrary.h
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
#import <id3tag.h>
#import <Foundation/Foundation.h>
#import "MFCommonDefines.h"
#import "MFMusicTrack.h"
#import "MFID3Tag.h"

// Main class of MFMusicLibrary API. Use the shared library instance for generic
// iPod database manipulation operations.
// Use the instance methods to retrieve and add or delete track information.


@interface MFMusicLibrary: NSObject {
	Itdb_iTunesDB *itdb;
}

// The shared library instance
// arguments: none
// returns: the shared music library or nil upon failure (should not happen at all...)
+ (id) sharedLibrary;

// Write all changes to the filesystem
// arguments: none
// returns: YES upon success, NO upon failure
- (BOOL) write;

// Refresh all data of the library
// If you've just added tracks to the library, then
// don't call this before doing a -write,
// as it destroys all unwritten/unsaved changes
- (void) refreshContents;

// Total number of playlists
// arguments: none
// Returns: the number of playlists on the device
- (uint32_t) numberOfPlaylists;

// Return a playlist name given an index:
// arguments:
// idx: integer representing the place of the playlist in the library
// returns: the corresponding playlists's nams or nil if it's nonexistent
- (NSString *) playlistNameForIndex:(uint32_t)idx;

// Create a playlist with a given name
// and add it to the music library
// arguments:
// name: an NSString representing the name of the playlist to be created
// returns: void
- (void) createPlaylistWithName:(NSString *)name;

// Remove a playlist from the music library given a name
// arguments:
// name: an NSString representing the playlist to be removed
// returns: void
- (void) removePlaylistWithName:(NSString *)name;

// Number of tracks in the library
// arguments: none
// returns: the total number of tracks in the iPod music library
- (uint32_t) numberOfTracks;

// A track in the music library
// arguments:
// index: the index of the requested track
// returns: an MFMusicTrack object representing the specified track
- (MFMusicTrack *) trackForIndex:(uint32_t)index;

// Delete a track from the music library completely
// arguments:
// index: the index of the track to be removed
// returns: void
- (void) removeTrackForIndex:(uint32_t)index;

// Number of tracks in a specified playlist
// arguments:
// name: the name of the playlist to get the number of tracks of
// returns: the number of tracks found
- (uint32_t) numberOfTracksInPlaylist:(NSString *)name;

// A track in a specified playlist
// arguments:
// index: the index of the track in the playlist
// name: an NSString representing the playlist's name
// returns: an MFMusicTrack object
- (MFMusicTrack *) trackForIndex:(uint32_t)index inPlaylist:(NSString *)name;

// Delete a track witb the specified index
// from a given playlist only
// arguments:
// index: the index of the track inside the playlist
// to be removed
// name: an NSString representing a playlist
// returns: void
- (void) removeTrackForIndex:(uint32_t)index fromPlaylist:(NSString *)name;

// add a file from filesystem, reading ID3 info automatically
// arguments:
// path: an NSString representation of the full path to the audio file
// returns: YES upon success, NO upon failure
- (BOOL) addFile:(NSString *)path;

// add a file from filesystem, providing song info by hand
// arguments:
// path: an NSString representation of the full path to the audio file
// track: an MFMusicTrack containing the metadata information
// returns: YES upon success, NO upon failure
- (BOOL) addFile:(NSString *)path asTrack:(MFMusicTrack *)track;

// Add a file from filesystem, to a specified playlist
// arguments:
// path: an NSString representation of the full path to the audio file
// name: an NSString object representing a specific playlist on the device
// returns: YES upon success, NO opun failure
- (BOOL) addFile:(NSString *)path toPlaylist:(NSString *)name;

// Add a file from filesystem, to a specified playlist, providing metadata by hand
// arguments:
// path: an NSString representation of the full path to the audio file
// track: an MFMusicTrack object containin the relevant metadata
// name: an NSString object representing a specific playlist on the device
// returns: YES upon success, NO opun failure
- (BOOL) addFile:(NSString *)path asTrack:(MFMusicTrack *)track toPlaylist:(NSString *)name;

@end

