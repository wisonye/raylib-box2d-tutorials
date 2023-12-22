// const b = @cImport({
//     @cInclude("box2d/box2d.h");
//     @cInclude("box2d/geometry.h");
//     @cInclude("box2d/math.h");
//     @cInclude("test_macros.h");
//     @cInclude("stdio.h");
// });

const std = @import("std");
const print = std.debug.print;

// This is a simple example of building and running a simulation
// using Box2D. Here we create a large ground box and a small dynamic
// box.
// There are no graphics for this example. Box2D is meant to be used
// with your rendering engine in your game engine.
pub fn main() !void {
    print("\n>>> asdfasdf", .{});

    // // Define the gravity vector.
    // b.b2Vec2 gravity = {0.0f, -10.0f};

    // // Construct a world object, which will hold and simulate the rigid bodies.
    // b.b2WorldDef worldDef = b.b2DefaultWorldDef();
    // worldDef.gravity = gravity;

    // b.b2WorldId worldId = b.b2CreateWorld(&worldDef);

    // // Define the ground body.
    // b.b2BodyDef groundBodyDef = b.b2DefaultBodyDef();
    // groundBodyDef.position = (b2Vec2){0.0f, -10.0f};

    // // Call the body factory which allocates memory for the ground body
    // // from a pool and creates the ground box shape (also from a pool).
    // // The body is also added to the world.
    // b.b2BodyId groundBodyId = b.b2World_CreateBody(worldId, &groundBodyDef);

    // // Define the ground box shape. The extents are the half-widths of the box.
    // b.b2Polygon groundBox = b.b2MakeBox(50.0f, 10.0f);

    // // Add the box shape to the ground body.
    // b.b2ShapeDef groundShapeDef = b.b2DefaultShapeDef();
    // b.b2Body_CreatePolygon(groundBodyId, &groundShapeDef, &groundBox);

    // // Define the dynamic body. We set its position and call the body factory.
    // b.b2BodyDef bodyDef = b.b2DefaultBodyDef();
    // bodyDef.type = b.b2_dynamicBody;
    // bodyDef.position = (b.b2Vec2){0.0f, 4.0f};
    // b.b2BodyId bodyId = b.b2World_CreateBody(worldId, &bodyDef);

    // // Define another box shape for our dynamic body.
    // b.b2Polygon dynamicBox = b.b2MakeBox(1.0f, 1.0f);

    // // Define the dynamic body shape
    // b.b2ShapeDef shapeDef = b.b2DefaultShapeDef();

    // // Set the box density to be non-zero, so it will be dynamic.
    // shapeDef.density = 1.0f;

    // // Override the default friction.
    // shapeDef.friction = 0.3f;

    // // Add the shape to the body.
    // b.b2Body_CreatePolygon(bodyId, &shapeDef, &dynamicBox);

    // // Prepare for simulation. Typically we use a time step of 1/60 of a
    // // second (60Hz) and 10 iterations. This provides a high quality simulation
    // // in most game scenarios.
    // f32 timeStep = 1.0f / 60.0f;
    // i32 velocityIterations = 6;
    // i32 relaxIterations = 2;

    // b.b2Vec2 position = b.b2Body_GetPosition(bodyId);
    // float angle = b.b2Body_GetAngle(bodyId);

    // // This is our little game loop.
    // for (int32_t i = 0; i < 60; ++i)
    // {
    // 	// Instruct the world to perform a single step of simulation.
    // 	// It is generally best to keep the time step and iterations fixed.
    // 	b.b2World_Step(worldId, timeStep, velocityIterations, relaxIterations);

    // 	// Now print the position and angle of the body.
    // 	position = b.b2Body_GetPosition(bodyId);
    // 	angle = b.b2Body_GetAngle(bodyId);

    // 	//printf("%4.2f %4.2f %4.2f\n", position.x, position.y, angle);
    // }

    // // When the world destructor is called, all bodies and joints are freed. This can
    // // create orphaned ids, so be careful about your world management.
    // b.b2DestroyWorld(worldId);
}

// int EmptyWorld(void)
// {
// 	b2WorldDef worldDef = b2DefaultWorldDef();
// 	b2WorldId worldId = b2CreateWorld(&worldDef);
// 	ENSURE(b2World_IsValid(worldId) == true);

// 	float timeStep = 1.0f / 60.0f;
// 	int32_t velocityIterations = 6;
// 	int32_t relaxIterations = 2;

// 	for (int32_t i = 0; i < 60; ++i)
// 	{
// 		b2World_Step(worldId, timeStep, velocityIterations, relaxIterations);
// 	}

// 	b2DestroyWorld(worldId);

// 	ENSURE(b2World_IsValid(worldId) == false);

// 	return 0;
// }
