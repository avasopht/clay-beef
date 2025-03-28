using System;
using System.Collections;
using System.Diagnostics;

using static RaylibBeef.Raylib;
using static Clay.Clay;

namespace example;

class ClayHomepage
{
	public enum FontId : uint16 : c_int
	{
		case Title56 = 1;
		case Title52 = 2;
		case Title48 = 3;
		case Title36 = 4;
		case Title32 = 5;
		case Body36 = 6;
		case Body30 = 7;
		case Body28 = 8;
		case Body24 = 9;
		case Body16 = 10;
		case Body12 = 11;

		public static implicit operator UnderlyingType(Self value);
	}

	const Color COLOR_BLACK = .(0, 0, 0, 255);
	const Color COLOR_LIGHT = .(244, 235, 230, 255);
	const Color COLOR_LIGHT_HOVER = .(224, 215, 210, 255);
	const Color COLOR_RED = .(168, 66, 28, 255);
	const Color COLOR_RED_HOVER = .(148, 46, 8, 255);
	const Color COLOR_ORANGE = .(225, 138, 50, 255);
	const Color COLOR_BLUE = .(111, 173, 162, 255);

	// Colors for top stripe
	const Color COLOR_TOP_BORDER_1 = .(168, 66, 28, 255);
	const Color COLOR_TOP_BORDER_2 = .(223, 110, 44, 255);
	const Color COLOR_TOP_BORDER_3 = .(225, 138, 50, 255);
	const Color COLOR_TOP_BORDER_4 = .(236, 189, 80, 255);
	const Color COLOR_TOP_BORDER_5 = .(240, 213, 137, 255);

	const Color COLOR_BLOB_BORDER_1 = .(168, 66, 28, 255);
	const Color COLOR_BLOB_BORDER_2 = .(203, 100, 44, 255);
	const Color COLOR_BLOB_BORDER_3 = .(225, 138, 50, 255);
	const Color COLOR_BLOB_BORDER_4 = .(236, 159, 70, 255);
	const Color COLOR_BLOB_BORDER_5 = .(240, 189, 100, 255);

	static RaylibBeef.Texture2D Check1;
	static RaylibBeef.Texture2D Check2;
	static RaylibBeef.Texture2D Check3;
	static RaylibBeef.Texture2D Check4;
	static RaylibBeef.Texture2D Check5;
	static RaylibBeef.Texture2D Declarative;
	static RaylibBeef.Texture2D Debugger;

	static TextElementConfig headerTextConfig = .()
		{
			font = FontId.Body24,
			size = 24,
			color = .(61, 26, 5, 255)
		};

	static TextElementConfig blobTextConfig = .()
		{
			font = FontId.Body30,
			size = 30,
			color = .(244, 235, 230, 255)
		};

	static void* offset;
	static uint32 sActiveRendererIndex = 0;

	static RaylibBeef.Texture LoadTexture(String imagePath)
	{
		return LoadTextureFromImage(LoadImage(imagePath));
	}

	static uint8 FloatToUint8(float f)
	{
		return (uint8)Math.Floor(f);
	}

	static Color ClayToRaylibColor(Color color)
	{
		return .(FloatToUint8(color.r), FloatToUint8(color.g), FloatToUint8(color.b), FloatToUint8(color.a));
	}

	static void OnError(ErrorData data)
	{
		Debug.WriteLine(scope String(data.errorText.chars));
	}

	public static void Init()
	{
		RendererRaylib.LoadFont(FontId.Title56, 56, "resource/fonts/Calistoga-Regular.ttf");
		RendererRaylib.LoadFont(FontId.Title52, 52, "resource/fonts/Calistoga-Regular.ttf");
		RendererRaylib.LoadFont(FontId.Title48, 48, "resource/fonts/Calistoga-Regular.ttf");
		RendererRaylib.LoadFont(FontId.Title36, 36, "resource/fonts/Calistoga-Regular.ttf");
		RendererRaylib.LoadFont(FontId.Title32, 32, "resource/fonts/Calistoga-Regular.ttf");
		RendererRaylib.LoadFont(FontId.Body36, 36, "resource/fonts/Quicksand-Semibold.ttf");
		RendererRaylib.LoadFont(FontId.Body30, 30, "resource/fonts/Quicksand-Semibold.ttf");
		RendererRaylib.LoadFont(FontId.Body28, 28, "resource/fonts/Quicksand-Semibold.ttf");
		RendererRaylib.LoadFont(FontId.Body24, 24, "resource/fonts/Quicksand-Semibold.ttf");
		RendererRaylib.LoadFont(FontId.Body16, 16, "resource/fonts/Quicksand-Semibold.ttf");
		RendererRaylib.LoadFont(FontId.Body12, 32, "resource/fonts/Quicksand-Semibold.ttf");

		Check1 = LoadTexture("resource/images/check_1.png");
		Check2 = LoadTexture("resource/images/check_2.png");
		Check3 = LoadTexture("resource/images/check_3.png");
		Check4 = LoadTexture("resource/images/check_4.png");
		Check5 = LoadTexture("resource/images/check_5.png");
		Declarative = LoadTexture("resource/images/declarative.png");
		Debugger = LoadTexture("resource/images/debugger.png");

		let capacity = Clay_MinMemorySize();

		offset = Internal.StdMalloc((.)capacity);

		let arena = Clay_CreateArenaWithCapacityAndMemory(capacity, (uint8*)offset);

		Clay_Initialize(arena, .(GetScreenWidth(), GetScreenHeight()), ErrorHandler( => OnError, null));
		Clay_SetMeasureTextFunction( => RendererRaylib.MeasureText, null);
	}

	public static void Cleanup()
	{
		Internal.StdFree(offset);
	}

	static void LandingPageBlob(uint32 index, uint16 size, Color color, String text, RaylibBeef.Texture* image)
	{
#pragma format disable
		UI(.() {
			id = ID("HeroBlob", index),
			layout = .() { 
				alignment = ChildAlignment { x = .Left, y = .Center },
				sizing = Sizing { width = Grow(0, 480) },
				padding = Padding(16),
				gap = 16
			},
			cornerRadius = CornerRadius(10),
			border = .() {
				width = .(2),
				color = color
			}
		}, scope () => {
			UI(.() {
				id = ID("CheckImage", index),
				layout = .() {  
					sizing = .(Fixed(32), Fixed(32))
				},
				image = .() {
					data = image,
					dimensions = .(128, 128)
				}
			});

			Text(text, .() { 
				size = size, 
				font = FontId.Body24,
				color = color 
			});
		});
#pragma format restore
	}

	static void LandingPageDesktop()
	{
		let windowHeight = GetScreenHeight();

#pragma format disable
	    UI(.() {
			id = ID("LandingPage1Desktop"), 
			layout = .() { 
				sizing = Sizing {
					width = Percent(1),
					height = Fixed(windowHeight - 70)
				}, 
				alignment = ChildAlignment {
					y = .Center
				},
				padding = Padding(50, 50, 0, 0)
			}
		}, scope () => {
			UI(.() {
				id = ID("LandingPage1"), 
				layout = .() { 
					sizing = Sizing { width = Percent(1), height = Percent(1) },
					alignment = ChildAlignment { x = .Center, y = .Center },
					padding = Padding(32),
					direction = .LeftToRight,
					gap = 32
				}, 
				border = .() {
					width = .(2, 2, 0, 0, 0),
					color = COLOR_RED
				}
			}, scope () => {
				UI(.() {
					id = ID("LeftText"), 
					layout = .() { 
						sizing = Sizing { width = Percent(0.55f) }, 
						gap = 8,
						direction = .TopToBottom
					}
				}, scope () => {
					Text("Clay is a flex-box style UI auto layout library in C, with declarative syntax and microsecond performance.", .() { 
						size = 56, 
						font = FontId.Title56, 
						color = COLOR_RED 
					});

					UI(.() {
						id = ID("LandingPageSpacer"), 
						layout = .() { 
							sizing = .(GrowMin(1), Fixed(32)) 
						}
					});

					Text("Clay is laying out this webpage right now!", .() { 
						size = 36, 
						font = FontId.Title36, 
						color = COLOR_ORANGE 
					});
				});

				UI(.() {
					id = ID("HeroImageOuter"), 
					layout = .() { 
						direction = .TopToBottom, 
						sizing = Sizing { width = Percent(0.45f) }, 
						alignment = ChildAlignment { x = .Center }, 
						gap = 16 
					}
				}, scope () => {
					LandingPageBlob(1, 32, COLOR_BLOB_BORDER_5, "High performance", &Check5);
					LandingPageBlob(2, 32, COLOR_BLOB_BORDER_4, "Flexbox-style responsive layout", &Check4);
					LandingPageBlob(3, 32, COLOR_BLOB_BORDER_3, "Declarative syntax", &Check3);
					LandingPageBlob(4, 32, COLOR_BLOB_BORDER_2, "Single .h file for C/C++", &Check2);
					LandingPageBlob(5, 32, COLOR_BLOB_BORDER_1, "Compile to 15kb .wasm", &Check1);
				});
			});
		});
#pragma format restore
	}

	static void LandingPageMobile()
	{
#pragma format disable
		UI(.() {
			id = ID("LandingPage1Mobile"), 
			layout = .() {
				direction = .TopToBottom, 
				//sizing = { width = Sizing(0),
				//height = Fit(min = windowHeight - 70) }, 
				alignment = .(.Center, .Center),
				padding = .(16, 16, 32, 32),
				gap = 32 
			}
		}, scope () => {
			UI(.() {
				id = ID("LeftText"), 
				layout = .() {
					//sizing = .() { width = Sizing(0) }, 
					direction = .TopToBottom,
					gap = 8 
				}
			}, scope () => {
				Text("Clay is a flex-box style UI auto layout library in C, with declarative syntax and microsecond performance.", .() { 
					size = 48, 
					font = FontId.Title48,
					color = COLOR_RED
				});

				UI(.() {
					id = ID("LandingPageSpacer"), 
					layout = .() { 
						//sizing = .() { width = Sizing(0),height = Fixed(32) } 
					}
				});

				Text("Clay is laying out this webpage right now!", .() { 
					size = 32, 
					font = FontId.Title36,color = COLOR_ORANGE 
				});
			});

			UI(.() {
				id = ID("HeroImageOuter"), 
				layout = .() {
					direction = .TopToBottom, 
					//sizing = { width = Sizing(0) }, 
					alignment = .(.Center, .Top),
					gap = 16 
				}
			}, scope () => {
				LandingPageBlob(1, 28, COLOR_BLOB_BORDER_5, "High performance", &Check5);
				LandingPageBlob(2, 28, COLOR_BLOB_BORDER_4, "Flexbox-style responsive layout", &Check4);
				LandingPageBlob(3, 28, COLOR_BLOB_BORDER_3, "Declarative syntax", &Check3);
				LandingPageBlob(4, 28, COLOR_BLOB_BORDER_2, "Single .h file for C/C++", &Check2);
				LandingPageBlob(5, 28, COLOR_BLOB_BORDER_1, "Compile to 15kb .wasm", &Check1);
			});
		});
#pragma format restore
	}

	static void FeatureBlocksDesktop()
	{
#pragma format disable
		UI(.() {
			id = ID("FeatureBlocksOuter"), 
			layout = .() { 
				sizing = .(Grow(0, 0), Grow(0, 0))
			}
		}, scope () => {
			UI(.() {
				id = ID("FeatureBlocksInner"), 
				layout = .() { 
					sizing = .(Grow(0, 0), Grow(0, 0)),
					alignment = .(0, .Center)
				},
				border = .() {
					width = BorderWidth { betweenChildren = 2 },
					color = COLOR_RED
				}
			}, scope() => {

				let textConfig = TextElementConfig { 
					size = 24, 
					font = FontId.Body24, 
					color = COLOR_RED 
				};

				UI(.() {
					id = ID("HFileBoxOuter"), 
					layout = .() { direction = .TopToBottom, 
						sizing = Sizing { width = Percent(0.5f) },
						alignment = .(0, .Center),
						padding = .(50, 50, 32, 32), 
						gap = 8
					}
				}, scope () => {
					UI(.() {
						id = ID("HFileIncludeOuter"), 
						layout = .() {
							padding = .(8, 8, 4, 4)
						},
						backgroundColor = COLOR_RED,
						cornerRadius = CornerRadius(8)
					}, scope () => {
						Text("#include clay.h", .() { 
							size = 24, 
							font = FontId.Body24, 
							color = COLOR_LIGHT 
						});
					});

					Text("~2000 lines of C99.", textConfig);

					Text("Zero dependencies, including no C standard library.", textConfig);
				});

				UI(.() {
					id = ID("BringYourOwnRendererOuter"), 
					layout = .() { direction = .TopToBottom, 
						sizing = Sizing { width = Percent(0.5f) },
						alignment = .(0, .Center), 
						padding = .(50, 50, 32, 32), 
						gap = 8
					}
				}, scope () => {
					Text("Renderer agnostic.", .() {
						font = FontId.Body24, 
						size = 24, 
						color = COLOR_ORANGE 
					});

					Text("Layout with clay, then render with Raylib, WebGL Canvas or even as HTML.", textConfig);

					Text("Flexible output for easy compositing in your custom engine or environment.", textConfig);
				});
			});
		});
#pragma format restore
	}

	static void FeatureBlocksMobile()
	{
#pragma format disable
//		/*UI(.() {
//			id = ID("FeatureBlocksInner"), 
//			layout = .() { direction = .TopToBottom, 
//		sizing = { Sizing(0) } 
//		}, 
//		border = { 
//			betweenChildren = { width = 2, 
//			color = COLOR_RED } 
//			})) {
//			TextElementConfig *textConfig = TextConfig({ 
//				size = 24, 
//				font = FontId.Body24, 
//				color = COLOR_RED 
//			});
//			UI(.() {
//				id = ID("HFileBoxOuter"), 
//				layout = .() { direction = .TopToBottom, 
//			sizing = { Sizing(0) }, 
//			alignment = {0, .AlignYCenter}, 
//			padding = {16, 16, 32, 32}, 
//			gap = 8 
//			})) {
//				UI(.() {
//					id = ID("HFileIncludeOuter"), 
//					layout = .() { padding = {8, 4} 
//				}, Rectangle({ color = COLOR_RED, cornerRadius = CLAY_CORNER_RADIUS(8) 
//				})) {
//					Text("#include clay.h", .() { 
//						size = 24, 
//						font = FontId.Body24, 
//						color = COLOR_LIGHT 
//					}));
//				}
//				Text("~2000 lines of C99.", textConfig);
//				Text("Zero dependencies, including no C standard library.", textConfig);
//			}
//			UI(.() {
//				id = ID("BringYourOwnRendererOuter"), 
//				layout = .() { direction = .TopToBottom, 
//			sizing = { Sizing(0) }, 
//			alignment = {0, .AlignYCenter}, 
//			padding = {16, 16, 32, 32}, 
//			gap = 8 
//			})) {
//				Text("Renderer agnostic.", .() { font = FontId.Body24, 
//				size = 24, 
//				color = COLOR_ORANGE 
//				}));
//				Text("Layout with clay, then render with Raylib, WebGL Canvas or even as HTML.", textConfig);
//				Text("Flexible output for easy compositing in your custom engine or environment.", textConfig);
//			}
//		}*/
#pragma format restore
	}

	static void DeclarativeSyntaxPageDesktop()
	{
#pragma format disable
		UI(.() {
			id = ID("SyntaxPageDesktop"), 
			layout = .() { 
				sizing = Sizing {
					width = Percent(1),
					height = FitMin(GetScreenHeight() - 50)
				}, 
				alignment = .(0, .Center),
				padding = .(50, 50, 0, 0)
			}
		}, scope () => {
			UI(.() {
				id = ID("SyntaxPage"), 
				layout = .() { 
					sizing = Sizing {
						width = Percent(1),
						height = Percent(1)
					},
					alignment = .(0, .Center), 
					padding = Padding(32),
					gap = 32
				},
				border = .() {
					width = .(2, 2, 0, 0, 0),
					color = COLOR_RED
				}
			}, scope () => {
				UI(.() {
					id = ID("SyntaxPageLeftText"), 
					layout = .() {
						sizing = Sizing {
							width = Percent(0.5f)
						},
						direction = .TopToBottom,
						gap = 8
					}
				}, scope () => {
					Text("Declarative Syntax", .() { 
						size = 56, 
						font = FontId.Title56, 
						color = COLOR_RED 
					});

					UI(.() {
						id = ID("SyntaxSpacer"), 
						layout = .() { 
							//sizing = { Sizing(max = 16) } 
						}
					});

					Text("Flexible and readable declarative syntax with nested UI element hierarchies.", .() { 
						size = 28, 
						font = FontId.Body36, 
						color = COLOR_RED 
					});

					Text("Mix elements with standard C code like loops, conditionals and functions.", .() { 
						size = 28, 
						font = FontId.Body36, 
						color = COLOR_RED 
					});

					Text("Create your own library of re-usable components from UI primitives like text, images and rectangles.", .() { 
						size = 28, 
						font = FontId.Body36, 
						color = COLOR_RED 
					});
				});

				UI(.() {
					id = ID("SyntaxPageRightImage"), 
					layout = .() { 
						sizing = Sizing {
							width = Percent(0.50f)
						}, 
						alignment = ChildAlignment { x = .Center } 
					}
				}, scope () => {
					UI(.() {
						id = ID("SyntaxPageRightImageInner"), 
						layout = .() { 
							sizing = Sizing {
								width = GrowMax(568)
							} 
						},
						image = .() {
							dimensions = .(1136, 1194),
							data = &Declarative
						}
					});
				});
			});
		});
#pragma format restore
	}

	static void DeclarativeSyntaxPageMobile()
	{
#pragma format disable
//		/*UI(.() {
//			id = ID("SyntaxPageDesktop"), 
//			layout = .() { direction = .TopToBottom, 
//		sizing = { Sizing(0), Fit(min = windowHeight - 50) }, 
//		alignment = {.Center, .AlignYCenter}, 
//		padding = {16, 16, 32, 32}, 
//		gap = 16 
//		})) {
//			UI(.() {
//				id = ID("SyntaxPageLeftText"), 
//				layout = .() { 
//				sizing = { Sizing(0) }, 
//			direction = .TopToBottom, 
//			gap = 8 
//			})) {
//				Text("Declarative Syntax", .() { 
//					size = 48, 
//					font = Font.Title56, 
//					color = COLOR_RED 
//				}));
//				UI(.() {
//					id = ID("SyntaxSpacer"), 
//					layout = .() { 
//					sizing = { Sizing(.max = 16) } 
//				})) {}
//				Text("Flexible and readable declarative syntax with nested UI element hierarchies.", .() { 
//					size = 28, 
//					font = Font.Body36, 
//					color = COLOR_RED 
//				}));
//				Text("Mix elements with standard C code like loops, conditionals and functions.", .() { 
//					size = 28, 
//					font = Font.Body36, 
//					color = COLOR_RED 
//				}));
//				Text("Create your own library of re-usable components from UI primitives like text, images and rectangles.", .() { 
//					size = 28, 
//					font = Font.Body36, 
//					color = COLOR_RED 
//				}));
//			}
//			UI(.() {
//				id = ID("SyntaxPageRightImage"), 
//				layout = .() { 
//				sizing = { Sizing(0) }, 
//			alignment = {.x = .Center} 
//			})) {
//				UI(.() {
//					id = ID("SyntaxPageRightImageInner"), 
//					layout = .() { 
//					sizing = { Sizing(.max = 568) } 
//					}, Image({ 
//						sourceDimensions = {1136, 1194}, 
//					sourceURL = "/clay/images/declarative.png" } )) {}
//			}
//		}*/
#pragma format restore
	}

	public static Color ColorLerp(Color a, Color b, float amount)
	{
		return .(
			a.r + (b.r - a.r) * amount,
			a.g + (b.g - a.g) * amount,
			a.b + (b.b - a.b) * amount,
			a.a + (b.a - a.a) * amount
			);
	}

	static void HighPerformancePageDesktop(float lerpValue)
	{
#pragma format disable
		UI(.() {
			id = ID("PerformanceOuter"), 
			layout = .() { 
				sizing = Sizing {
					width = Grow(0, 0),
					height = FitMin(GetScreenHeight() - 50)
				}, 
				alignment = .(0, .Center), 
				padding = .(82, 82, 32, 32), 
				gap = 64
			},
			backgroundColor = COLOR_RED
		}, scope() => {
			UI(.() {
				id = ID("PerformanceLeftText"), 
				layout = .() { 
					sizing = Sizing {
						width = Percent(0.50f)
					},
					direction = .TopToBottom, 
					gap = 8
				}
			}, scope () => {
				Text("High Performance", .() { 
					size = 52, 
					font = FontId.Title56, 
					color = COLOR_LIGHT 
				});

				Text("Fast enough to recompute your entire UI every frame.", .() { 
					size = 28, 
					font = FontId.Body28, 
					color = COLOR_LIGHT 
				});

				Text("Small memory footprint (3.5mb default with static allocation & reuse. No malloc / free.", .() { 
					size = 28, 
					font = FontId.Body28, 
					color = COLOR_LIGHT 
				});

				Text("Simplify animations and reactive UI design by avoiding the standard performance hacks.", .() { 
					size = 28, 
					font = FontId.Body28, 
					color = COLOR_LIGHT 
				});
			});

			String LOREM_IPSUM_TEXT = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";

			UI(.() {
				id = ID("PerformanceRightImageOuter"), 
				layout = .() { 
					sizing = Sizing {
						width = Percent(0.50f)
					}, 
					alignment = .(.Center, 0)
				},
				border = .(2, COLOR_LIGHT)
			}, scope () => {
				UI(.() {
					layout = .() { 
						sizing = .(GrowMin(0), Fixed(400))
					},
					backgroundColor = COLOR_LIGHT 
				}, scope() => {
					UI(.() {
						id = ID("AnimationDemoContainerLeft"), 
						layout = .() { 
							sizing = .(Percent(0.3f + 0.4f * lerpValue), GrowMin(0)),
							alignment = .(0, .Center), 
							padding = Padding(32) 
						},
						backgroundColor = ColorLerp(COLOR_RED, COLOR_ORANGE, lerpValue)
					}, scope () => {
						Text(LOREM_IPSUM_TEXT, .() { 
							size = 24, 
							font = FontId.Body24, 
							color = COLOR_LIGHT 
						});
					});

					UI(.() {
						id = ID("AnimationDemoContainerRight"), 
						layout = .() { 
							sizing = Sizing(GrowMin(0), GrowMin(0)),
							alignment = .(0, .Center),
							padding = Padding(32)
						},
						backgroundColor = ColorLerp(COLOR_ORANGE, COLOR_RED, lerpValue)
					}, scope () => {
						Text(LOREM_IPSUM_TEXT, .() { 
							size = 24, 
							font = FontId.Body24, 
							color = COLOR_LIGHT 
						});
					});
				});
			});
		});
#pragma format restore
	}

	static void HighPerformancePageMobile(float lerpValue)
	{
#pragma format disable
		UI(.() {
			id = ID("PerformanceOuter"),
			layout = .() {
				direction = .TopToBottom,
				sizing = Sizing {
					width = GrowMin(0),
					height = FitMin(GetScreenHeight() - 50)
				},
				alignment = .(.Center, .Center),
				padding = .(16, 16, 32, 32),
				gap = 32
			},
			backgroundColor = COLOR_RED
		}, scope () => {
			UI(.() {
				id = ID("PerformanceLeftText"),
				layout = .() {
					//sizing = { Sizing(0) },
					direction = .TopToBottom,
					gap = 8
				}
			}, scope () => {
				Text("High Performance", .() {
					size = 48,
					font = FontId.Title56,
					color = COLOR_LIGHT
				});

				UI(.() {
					id = ID("PerformanceSpacer"),
					layout = .() {
						//sizing = { Sizing(.max = 16) }
					}
				});

				Text("Fast enough to recompute your entire UI every frame.", .() {
					size = 28,
					font = FontId.Body36,
					color = COLOR_LIGHT
				});

				Text("Small memory footprint (3.5mb default with static allocation & reuse. No malloc / free.", .() {
					size = 28,
					font = FontId.Body36,
					color = COLOR_LIGHT
				});
				Text("Simplify animations and reactive UI design by avoiding the standard performance hacks.", .() {
					size = 28,
					font = FontId.Body36,
					color = COLOR_LIGHT
				});
			});

			String LOREM_IPSUM_TEXT = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";

			UI(.() {
				id = ID("PerformanceRightImageOuter"),
				layout = .() {
					sizing = .(Grow(0,0),Grow(0,0)),
					alignment = .(.Center, .Center)
				},
				backgroundColor = COLOR_BLACK
			}, scope () => {
				UI(.() {
					id = ID(""),
					layout = .() { 
						sizing = Sizing { height = Fixed(400) }
					},
					border = .(2, COLOR_LIGHT)
				}, scope () => {
					UI(.() {
						id = ID("AnimationDemoContainerLeft"),
						layout = .() {
							sizing = .(Percent(0.35f + 0.3f * lerpValue), GrowMin(0)),
							alignment = ChildAlignment { y = .Center },
							padding = Padding(16)
						},
						backgroundColor = ColorLerp(COLOR_RED, COLOR_ORANGE, lerpValue)
					}, scope () => {
						Text(LOREM_IPSUM_TEXT, .() {
							size = 24,
							font = FontId.Title56,
							color = COLOR_LIGHT
						});
					});

					UI(.() {
						id = ID("AnimationDemoContainerRight"), 
						layout = .() { 
							sizing = .(Grow(0, 0), Grow(0, 0)), 
							alignment = ChildAlignment { y = .Center }, 
							padding = Padding(16) 
						}
						//backgroundColor = ColorLerp(COLOR_ORANGE, COLOR_RED, lerpValue)
					}, scope () => {
						Text(LOREM_IPSUM_TEXT, .() { 
							size = 24, 
							font = FontId.Title56, 
							color = COLOR_LIGHT 
						});
					});
				});
			});
		});
#pragma format restore
	}

	static void HandleRendererButtonInteraction(ElementId elementId, PointerData pointerInfo, uint64* userData)
	{
#pragma format disable
//		if (pointerInfo.state == .ClayPointerDataPressedThisFrame) {
//			//sActiveRendererIndex = (.)userData;
//			//Clay_SetCullingEnabled(sActiveRendererIndex == 1);
//			//Clay_SetExternalScrollHandlingEnabled(sActiveRendererIndex == 0);
//		}
#pragma format restore
	}

	public static bool Clay_Hovered()
	{
		return false;
	}

	static void RendererButtonActive(String text)
	{
#pragma format disable
		UI(.() {
			layout = .(){
				sizing = Sizing { width = Fixed(300) },
				padding = Padding(16)
			},
			backgroundColor = Clay_Hovered() ? COLOR_RED_HOVER : COLOR_RED,
			cornerRadius = CornerRadius(10)
		}, scope () => {
			Text(text, .() {
				disablePointerEvents = true,
				size = 28,
				font = FontId.Body36,
				color = COLOR_LIGHT
			});
		});
#pragma format restore
	}

	static void RendererButtonInactive(String text, int64 rendererIndex)
	{
#pragma format disable
		UI(.() {
			layout = .() { 
				sizing = Sizing {
					width = Fixed(300)
				}, 
				padding = Padding(16) 
			},
			backgroundColor = Clay_Hovered() ? COLOR_LIGHT_HOVER : COLOR_LIGHT,
			cornerRadius = CornerRadius(10),
			border = .(2, COLOR_RED)
			//Clay_OnHover(HandleRendererButtonInteraction, rendererIndex)
		}, scope () => {
			Text(text, .() {
				//disablePointerEvents = true, 
				size = 28, 
				font = FontId.Body36, 
				color = COLOR_RED 
			});
		});
#pragma format restore
	}

	static void RendererPageDesktop()
	{
#pragma format disable
		UI(.() {
			id = ID("RendererPageDesktop"), 
			layout = .() { 
				sizing = .(GrowMin(0), FitMin(GetScreenHeight() - 50)), 
				alignment = .(0, .Center),  
				padding = .(50, 0)
			}
		}, scope () => {
			UI(.() {
				id = ID("RendererPage"), 
				layout = .() { 
					sizing = .(GrowMin(0), GrowMin(0)),  
					alignment = .(.Center, .Center), 
					padding = Padding(32),
					gap = 32 
				}, 
				border = .() {
					width = .(2, 2, 0, 0, 0),
					color = COLOR_RED
				}
			}, scope () => {
				UI(.() {
					id = ID("RendererLeftText"), 
					layout = .() { 
						sizing = Sizing { width = Percent(0.5f) },
						direction = .TopToBottom, 
						gap = 8
					}
				}, scope () => {
					Text("Renderer & Platform Agnostic", .() { 
						size = 52, 
						font = FontId.Title52, 
						color = COLOR_RED 
					});

					UI(.() {
						id = ID("RendererSpacerLeft"), 
						layout = .() { 
							sizing = Sizing { height = Fixed(16) }
						}
					});

					Text("Clay outputs a sorted array of primitive render commands, such as RECTANGLE, TEXT or IMAGE.", .() { 
						size = 28, 
						font = FontId.Body28, 
						color = COLOR_RED 
					});

					Text("Write your own renderer in a few hundred lines of code, or use the provided examples for Raylib, WebGL canvas and more.", .() { 
						size = 28, 
						font = FontId.Body28, 
						color = COLOR_RED 
					});

					Text("There's even an HTML renderer - you're looking at it right now!", .() { 
						size = 28, 
						font = FontId.Body28, 
						color = COLOR_RED 
					});
				});

				UI(.() {
					id = ID("RendererRightText"), 
					layout = .() { 
						sizing = .(Percent(0.5f), GrowMin(0)), 
						alignment = .(.Center, .Center), 
						direction = .TopToBottom, 
						gap = 16 
					}
				}, scope () => {
					Text("Try changing renderer!", .() { 
						size = 36, 
						font = FontId.Body36, 
						color = COLOR_ORANGE 
					});

					UI(.() {
						id = ID("RendererSpacerRight"), 
						layout = .() { 
							//sizing = { Sizing(.max = 32) } 
						}
					});

					if (sActiveRendererIndex == 0) {
						RendererButtonActive("HTML Renderer");
						RendererButtonInactive("Canvas Renderer", 1);
					} else {
						RendererButtonInactive("HTML Renderer", 0);
						RendererButtonActive("Canvas Renderer");
					}
				});
			});
		});
#pragma format restore
	}

	static void RendererPageMobile()
	{
#pragma format disable
		/*UI(.() {
			id = ID("RendererMobile"), 
			layout = .() { direction = .TopToBottom, 
		sizing = { Sizing(0), Fit(min = windowHeight - 50) }, 
		alignment = {.x = .Center, y = .AlignYCenter}, 
		padding = { 16, 16, 32, 32}, 
		gap = 32 
		}, Rectangle({ color = COLOR_LIGHT 
		})) {
			UI(.() {
				id = ID("RendererLeftText"), 
				layout = .() { 
				sizing = { Sizing(0) }, 
			direction = .TopToBottom, 
			gap = 8 
			})) {
				Text("Renderer & Platform Agnostic", .() { 
					size = 48, 
					font = Font.Title56, 
					color = COLOR_RED 
				}));
				UI(.() {
					id = ID("RendererSpacerLeft"), 
					layout = .() { 
					sizing = { Sizing(.max = 16) }})) {}
				Text("Clay outputs a sorted array of primitive render commands, such as RECTANGLE, TEXT or IMAGE.", .() { 
					size = 28, 
					font = Font.Body36, 
					color = COLOR_RED 
				}));
				Text("Write your own renderer in a few hundred lines of code, or use the provided examples for Raylib, WebGL canvas and more.", .() { 
					size = 28, 
					font = Font.Body36, 
					color = COLOR_RED 
				}));
				Text("There's even an HTML renderer - you're looking at it right now!", .() { 
					size = 28, 
					font = Font.Body36, 
					color = COLOR_RED 
				}));
			}
			UI(.() {
				id = ID("RendererRightText"), 
				layout = .() { 
				sizing = { Sizing(0) }, 
			direction = .TopToBottom, 
			gap = 16 
			})) {
				Text("Try changing renderer!", .() { 
					size = 36, 
					font = Font.Body36, 
					color = COLOR_ORANGE 
				}));
				UI(.() {
					id = ID("RendererSpacerRight"), 
					layout = .() { 
					sizing = { Sizing(.max = 32) }})) {}
				if (ACTIVE_RENDERER_INDEX == 0) {
					RendererButtonActive("HTML Renderer");
					RendererButtonInactive("Canvas Renderer", 1);
				} else {
					RendererButtonInactive("HTML Renderer", 0);
					RendererButtonActive("Canvas Renderer");
				}
			}
		}*/
#pragma format restore
	}

	static void DebuggerPageDesktop()
	{
#pragma format disable
		UI(.() {
			id = ID("DebuggerDesktop"), 
			layout = .() { 
				sizing = .(GrowMin(0), FitMin(GetScreenHeight() - 50)), 
				alignment = .(0, .Center),
				padding = .(82, 82, 32, 32),
				gap = 64 
			},
			backgroundColor = COLOR_RED
		}, scope () => {
			UI(.() {
				id = ID("DebuggerLeftText"), 
				layout = .() { 
					sizing = Sizing { width = Percent(0.5f) }, 
					direction = .TopToBottom, 
					gap = 8 
				}
			}, scope () => {
				Text("Integrated Debug Tools", .() { 
					size = 52, 
					font = FontId.Title56, 
					color = COLOR_LIGHT 
				});
	
				UI(.() {
					id = ID("DebuggerSpacer"), 
					layout = .() { 
						//sizing = { Sizing(.max = 16) }
					}
				});
	
				Text("Clay includes built in \"Chrome Inspector\"-style debug tooling.", .() { 
					size = 28, 
					font = FontId.Body36, 
					color = COLOR_LIGHT 
				});
	
				Text("View your layout hierarchy and config in real time.", .() { 
					size = 28, 
					font = FontId.Body36, 
					color = COLOR_LIGHT 
				});
	
				UI(.() {
					id = ID("DebuggerPageSpacer"), 
					layout = .() { 
						sizing = Sizing { width = Percent(100), height = Fixed(32) }
					}
				});
	
				Text("Press the \"d\" key to try it out now!", .() { 
					size = 32, 
					font = FontId.Title36, 
					color = COLOR_ORANGE 
				});
			});

			UI(.() {
				id = ID("DebuggerRightImageOuter"), 
				layout = .() { 
					sizing = Sizing {
						width = Percent(0.50f)
					},
					alignment = .(.Center, .Center)
				}
			}, scope () => {
				UI(.() {
					id = ID("DebuggerPageRightImageInner"), 
					layout = .() {
						sizing = Sizing {
							width = GrowMax(558)
						} 
					},
					image = .() {
						dimensions = .(1620, 1474),
						data = &Debugger
					}
				});
			});
		});
#pragma format restore
	}

	struct ScrollbarData
	{
		public Vector2 clickOrigin;
		public Vector2 positionOrigin;
		public bool mouseDown;
	};

	static ScrollbarData scrollbarData = .();
	static float animationLerpValue = -1.0f;

	static void TopBorder(String id, Color color)
	{
		UI(.()
			{
				id = ID(id),
				layout = .() { sizing = .(Percent(1), Fixed(4)) },
				backgroundColor = color
			});
	};

	static Array<RenderCommand> CreateLayout(bool mobileScreen, float lerpValue)
	{
		Clay_BeginLayout();

#pragma format disable
		UI(.() {
			id = ID("OuterContainer"),
			layout = .() {
				direction = .TopToBottom,
				sizing = Sizing { width = Percent(1), height = Percent(1) }
			},
			//backgroundColor = COLOR_LIGHT
			backgroundColor = Clay_Hovered() ? COLOR_LIGHT_HOVER : COLOR_LIGHT
		}, scope () => {
			
			UI(.() {
				id = ID("Header"),
				layout = .() {
					sizing = .(Percent(1), Fixed(50)),
					alignment = .( .Left, .Center),
					direction = .LeftToRight,
					gap = 16,
					padding = .(32, 32, 0, 0)
				}
			}, scope () => {
				Text("Clay", headerTextConfig);

				UI(.() {
					id = ID("Spacer"),
					layout = .() {
						sizing = Sizing {
							width = GrowMin(1)
						}
					}
				});

				if (!mobileScreen) {
					UI(.() {
						id = ID("LinkExamplesOuter"),
						layout = .() {
							direction = .LeftToRight,
							padding = .(8, 8, 0, 0)
						},
						backgroundColor = .(0, 0, 0, 0)
					}, scope () => {
						Text("Examples", .() {
							disablePointerEvents = true, 
							font = FontId.Body24, 
							size = 24, 
							color = .(61, 26, 5, 255)
						});
					});

					UI(.() {
						id = ID("LinkDocsOuter"),
						layout = .() {
							padding = .(8, 8, 0, 0)
						},
						backgroundColor = .(0, 0, 0, 0)
					}, scope () => {
						Text("Docs", .() {
							disablePointerEvents = true, 
							font = FontId.Body24, 
							size = 24, 
							color = .(61, 26, 5, 255)
						});
					});

					UI(.() {
						id = ID("DiscordLink"),
						layout = .() {
							padding = .(16, 16, 6, 6)
						},
						cornerRadius = CornerRadius(10),
						backgroundColor = Clay_Hovered() ? COLOR_LIGHT_HOVER : COLOR_LIGHT,
						border = .(2, COLOR_RED)
					}, scope () => {
						Text("Discord", .() {
							disablePointerEvents = true, 
							font = FontId.Body24, 
							size = 24, 
							color = .(61, 26, 5, 255)
						});
					});

					UI(.() {
						id = ID("GithubLink"),
						layout = .() {
							padding = .(16, 16, 6, 6)
						},
						cornerRadius = CornerRadius(10),
						backgroundColor = Clay_Hovered() ? COLOR_LIGHT_HOVER : COLOR_LIGHT,
						border = .(2, COLOR_RED)
					}, scope () => {
						Text("Github", .() {
							disablePointerEvents = true, 
							font = FontId.Body28, 
							size = 24, 
							color = .(61, 26, 5, 255)
						});
					});
				}
			});

			TopBorder("TopBorder1", COLOR_TOP_BORDER_5);
			TopBorder("TopBorder2", COLOR_TOP_BORDER_4);
			TopBorder("TopBorder3", COLOR_TOP_BORDER_3);
			TopBorder("TopBorder4", COLOR_TOP_BORDER_2);
			TopBorder("TopBorder5", COLOR_TOP_BORDER_1);

			UI(.() {
				id = ID("OuterScrollContainer"),
				scroll = .(false, true),
				layout = .() { 
					sizing = .(Percent(1), Percent(1)), 
					direction = .TopToBottom 
				},
				border = .() {
					width = BorderWidth { betweenChildren = 2 },
					color = COLOR_RED
				}
			}, scope () => {
				if (mobileScreen) {
					LandingPageMobile();
					FeatureBlocksMobile();
					DeclarativeSyntaxPageMobile();
					HighPerformancePageMobile(lerpValue);
					RendererPageMobile();
				} else {
					LandingPageDesktop();
					FeatureBlocksDesktop();
					DeclarativeSyntaxPageDesktop();
					HighPerformancePageDesktop(lerpValue);
					RendererPageDesktop();
					DebuggerPageDesktop();
				}
			});
		});

		if (!mobileScreen && sActiveRendererIndex == 0)
		{
			ScrollContainerData scrollData = Clay_GetScrollContainerData(Clay_GetElementId("OuterScrollContainer"));

			Color scrollbarColor = .(225, 138, 50, 120);

			if (scrollbarData.mouseDown)
			{
				scrollbarColor = .( 225, 138, 50, 200 );
			} else if (Clay_PointerOver(Clay_GetElementId("ScrollBar")))
			{
				scrollbarColor = .(  225, 138, 50, 160 );
			}

			float scrollHeight = scrollData.scrollContainerDimensions.height - 12;

			/*UI(.() {
				id = ID("ScrollBar"),
				floating = .()
				{
					offset = .(-6, -(scrollData.scrollPosition.y / scrollData.contentDimensions.height) * scrollHeight + 6),
					zIndex = 1,
					parentId = Clay_GetElementId("OuterScrollContainer").id,
					attachPoints = .() {
						element = .RightTop, parent = .RightTop }
				},
				layout = .(){
					sizing = .(Fixed(10), Fixed((scrollHeight / scrollData.contentDimensions.height) * scrollHeight))
				},
				cornerRadius = CornerRadius(5),
				backgroundColor = scrollbarColor
			});*/
		}
#pragma format restore

		return Clay_EndLayout();
	}

	public static void Update(float mouseX, float mouseY, float wheelX, float wheelY, bool mousePressed)
	{
		Clay_SetLayoutDimensions(.(GetScreenWidth(), GetScreenHeight()));
		Clay_SetPointerState(.(mouseX, mouseY), mousePressed);
		Clay_UpdateScrollContainers(true, .(wheelX * 10, wheelY * 10), GetFrameTime());

		ScrollContainerData scrollContainerData = Clay_GetScrollContainerData(Clay_GetElementId("OuterScrollContainer"));

		if (scrollContainerData.contentDimensions.height > 0)
		{
			if (IsKeyDown(.KeyDown))
			{
				scrollContainerData.scrollPosition.y = scrollContainerData.scrollPosition.y - 50;
			} else if (IsKeyDown(.KeyUp))
			{
				scrollContainerData.scrollPosition.y = scrollContainerData.scrollPosition.y + 50;
			}
		}

		animationLerpValue += GetFrameTime();
		if (animationLerpValue > 1)
		{
			animationLerpValue -= 2;
		}

		var renderCommands = CreateLayout(false, animationLerpValue < 0 ? (animationLerpValue + 1) : (1 - animationLerpValue));

		RendererRaylib.Render(&renderCommands);
	}
}