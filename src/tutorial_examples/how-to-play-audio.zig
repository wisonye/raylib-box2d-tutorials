const rl = @cImport({
    @cInclude("raylib.h");
});

const GAME_FPS = 60;

const TRON_DARK = rl.Color{ .r = 0x23, .g = 0x21, .b = 0x1B, .a = 0xFF };
const TRON_LIGHT_BLUE = rl.Color{ .r = 0xAC, .g = 0xE6, .b = 0xFE, .a = 0xFF };
const TRON_BLUE = rl.Color{ .r = 0x6F, .g = 0xC3, .b = 0xDF, .a = 0xFF };
const TRON_YELLOW = rl.Color{ .r = 0xFF, .g = 0xE6, .b = 0x4D, .a = 0xFF };
const TRON_ORANGE = rl.Color{ .r = 0xFF, .g = 0x9F, .b = 0x1C, .a = 0xFF };
const TRON_RED = rl.Color{ .r = 0xF4, .g = 0x47, .b = 0x47, .a = 0xFF };

///
///
///
pub fn main() !void {
    // Create a window with a particular size and title
    rl.InitWindow(1024, 768, "How to play audio");
    defer rl.CloseWindow();

    // Set refresh rate (AKA, FPS: Frame Per Second)
    rl.SetTargetFPS(GAME_FPS);

    // Set tracing log level (DEBUG/INFO/WARN/ERROR)
    rl.SetTraceLogLevel(rl.LOG_DEBUG);

    // Hide the cursor
    // rl.HideCursor();

    // Optional, enable waiting for events (keyboard/mouse/etc) on `EndDrawing()`,
    // no automatic event polling, save power consumsion.
    // rl.EnableEventWaiting();

    // Initialize audio device
    rl.InitAudioDevice();

    //
    // Load background music and sound effects
    //
    const sound_effect = rl.LoadSound("resources/sound-effects/enable_fireball.wav");
    const background_music = rl.LoadMusicStream("resources/background-musics/be-jammin.mp3");

    //
    // Play background music
    //
    rl.PlayMusicStream(background_music);

    //
    // Game loop
    //
    var is_running = true;
    var background_music_paused = false;

    // Time played normalized [0.0f..1.0f]
    var timePlayed: f32 = 0.0;

    while (is_running) {
        // -------------------------------------------------------------
        // Game logic
        // -------------------------------------------------------------

        //
        // Press `Q` to exit
        //
        if (rl.IsKeyPressed(rl.KEY_Q)) {
            is_running = false;
            rl.TraceLog(rl.LOG_DEBUG, ">>> Press 'Q' to exit");
        }

        //
        // Press `SPACE` to restart music playing (stop and play)
        //
        if (rl.IsKeyPressed(rl.KEY_SPACE)) {
            rl.StopMusicStream(background_music);
            rl.PlayMusicStream(background_music);
            rl.TraceLog(rl.LOG_DEBUG, ">>> Restart background music.");
        }

        //
        // Press `P` to pause/resume music playing
        //
        if (rl.IsKeyPressed(rl.KEY_P)) {
            background_music_paused = !background_music_paused;

            if (background_music_paused) {
                rl.PauseMusicStream(background_music);
                rl.TraceLog(rl.LOG_DEBUG, ">>> Paused background music.");
            } else {
                rl.ResumeMusicStream(background_music);
                rl.TraceLog(rl.LOG_DEBUG, ">>> Resumed background music.");
            }
        }

        //
        // Press `S` to play sound effect
        //
        if (rl.IsKeyPressed(rl.KEY_S)) {
            rl.PlaySound(sound_effect);
            rl.TraceLog(rl.LOG_DEBUG, ">>> Play sound effect.");
        }

        //
        // Update music buffer with new stream data
        //
        rl.UpdateMusicStream(background_music);

        //
        // Get normalized time played for current music stream, used to update
        // progress bar
        //
        timePlayed = rl.GetMusicTimePlayed(background_music) / rl.GetMusicTimeLength(background_music);

        // Make sure time played is no longer than music
        if (timePlayed > 1.0) {
            timePlayed = 1.0;
        }

        // -------------------------------------------------------------
        // Redraw the entire frame
        // -------------------------------------------------------------
        rl.BeginDrawing();

        // Clear background
        rl.ClearBackground(TRON_DARK);

        //
        // Background music progress bar
        //
        rl.DrawRectangle(200, 180, 400, 12, TRON_LIGHT_BLUE);
        rl.DrawRectangle(
            200,
            180,
            @as(c_int, @intFromFloat(timePlayed * 400.0)),
            12,
            TRON_ORANGE,
        );
        rl.DrawRectangleLines(200, 180, 400, 12, rl.WHITE);

        //
        // Draw tips
        //
        rl.DrawText("Press 'SPACE' to restart music", 200, 230, 20, rl.GRAY);
        rl.DrawText("Press 'P' to pause/resume music", 200, 260, 20, rl.GRAY);
        rl.DrawText("Press 'S' to play sound effect", 200, 290, 20, rl.GRAY);

        rl.EndDrawing();
    }

    //
    // Unload and close audio device
    //
    rl.UnloadMusicStream(background_music);
    rl.UnloadSound(sound_effect);
    rl.CloseAudioDevice();
}
