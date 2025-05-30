using System;
using System.Interop;

namespace Clay;


public static class Clay
{
	public typealias OnHoverFunction = function void(ElementId elementId, PointerData pointerData, void* userData);

	[Comptime] public static bool Clay_PointerOver(System.String id)
	{
		return Clay_PointerOver(ID(id));
	}
	
	public static bool Clay_PointerOver(System.String id)
	{
		return Clay_PointerOver(ID(id));
	}

	[CRepr]
	public struct Array<T>
	{
		public int32 capacity;
		public int32 length;
		public T* internalArray;
	}

	[CRepr]
	public struct String
	{
		public int32 length;
		public char8* chars;

		public this(int32 length, char8* chars)
		{
			this.length = length;
			this.chars = chars;
		}
	}

	[CRepr]
	public struct StringSlice
	{
		public int32 length;
		public char8* chars;
		public char8* baseChars;
	}

	[CRepr]
	public struct Arena
	{
		public uint* nextAllocation;
		public uint* capacity;
		public char8* memory;
	}

	[CRepr]
	public struct Dimensions
	{
		public float width, height;

		public this(float width, float height)
		{
			this.width = width;
			this.height = height;
		}
	}

	[CRepr]
	public struct Vector2
	{
		public float x, y;

		public this(float x, float y)
		{
			this.x = x;
			this.y = y;
		}
	}

	[CRepr]
	public struct Color
	{
		public float r = 0, g = 0, b = 0, a = 0;

		public this(float r = 0, float g = 0, float b = 0, float a = 0)
		{
			this.r = r;
			this.g = g;
			this.b = b;
			this.a = a;
		}

		public implicit static operator Color(RaylibBeef.Color c) => .(c.r, c.g, c.b, c.a);
	}

	[CRepr]
	public struct BoundingBox
	{
		public float x, y, width, height;
	}

	[CRepr]
	public struct ElementId
	{
		public uint32 id, offset, baseId;
		public String stringId;
	}

	[CRepr]
	public struct CornerRadius
	{
		public float topLeft, topRight, bottomLeft, bottomRight;

		public this(float topLeft, float topRight, float bottomLeft, float bottomRight)
		{
			this.topLeft = topLeft;
			this.topRight = topRight;
			this.bottomLeft = bottomLeft;
			this.bottomRight = bottomRight;
		}

		public this(float radius)
		{
			this.topLeft = this.topRight = this.bottomLeft = this.bottomRight = radius;
		}
	}

	public enum ElementConfigType : c_int
	{
		None,
		Border,
		Floating,
		Scroll,
		Image,
		Text,
		Custom,
		Shared,
	}

	public enum LayoutDirection : c_int
	{
		LeftToRight,
		TopToBottom,
	}

	public enum LayoutAlignmentX : c_int
	{
		Left,
		Right,
		Center,
	}

	public enum LayoutAlignmentY : c_int
	{
		Top,
		Bottom,
		Center,
	}

	public enum SizingType : c_int
	{
		Fit,
		Grow,
		Percent,
		Fixed,
	}

	[CRepr]
	public struct ChildAlignment
	{
		public LayoutAlignmentX x = .Left;
		public LayoutAlignmentY y = .Top;

		public this(LayoutAlignmentX x, LayoutAlignmentY y)
		{
			this.x = x;
			this.y = y;
		}
	}

	[CRepr]
	public struct SizingMinMax
	{
		public float min, max;

		public this(float min, float max)
		{
			this.min = min;
			this.max = max;
		}
	}

	[CRepr, Union]
	public struct SizingConstraints
	{
		public SizingMinMax minMax;
		public float percent;

		public this(SizingMinMax minMax)
		{
			this.minMax = minMax;
		}

		public this(float percent)
		{
			this.percent = percent;
		}
	}

	[CRepr]
	public struct SizingAxis
	{
		public SizingConstraints constraints;
		public SizingType type;

		public this(SizingType type, SizingConstraints constraints)
		{
			this.constraints = constraints;
			this.type = type;
		}

		public this(SizingType type, SizingMinMax minMax)
		{
			this.constraints = .(minMax);
			this.type = type;
		}

		public this(SizingType type, float percent)
		{
			this.constraints = .(percent);
			this.type = type;
		}
	}

	[CRepr]
	public struct Sizing
	{
		public SizingAxis width;
		public SizingAxis height;

		public this(SizingAxis width, SizingAxis height)
		{
			this.width = width;
			this.height = height;
		}
	}

	[CRepr]
	public struct Padding
	{
		public uint16 left = 0, right = 0, top = 0, bottom = 0;

		public this(uint16 left, uint16 right, uint16 top, uint16 bottom)
		{
			this.left = left;
			this.right = right;
			this.top = top;
			this.bottom = bottom;
		}

		public this(uint16 padding)
		{
			this.left = this.right = this.top = this.bottom = padding;
		}

		public this(uint16 horizontal, uint16 vertical)
		{
			this.left = this.right = horizontal;
			this.top = this.bottom = vertical;
		}
	}

	[CRepr]
	public struct LayoutConfig
	{
		public Sizing sizing;
		public Padding padding;
		public uint16 gap;
		public ChildAlignment alignment;
		public LayoutDirection direction;
	}

	[CRepr]
	public struct RectangleElementConfig
	{
		public Color color;
	}

	public enum TextWrapMode : c_int
	{
		Words,
		Newlines,
		None,
	}

	[CRepr]
	public struct TextElementConfig
	{
		public Color color;
		public uint16 font, size, letterSpacing, lineHeight;
		public TextWrapMode wrap;
		public bool hashStringContents;
		public bool disablePointerEvents;
	}

	[CRepr]
	public struct ImageElementConfig
	{
		public void* data;
		public Dimensions dimensions;
	}

	public enum FloatingAttachPointType : c_int
	{
		LeftTop,
		LeftCenter,
		LeftBottom,
		CenterTop,
		CenterCenter,
		CenterBottom,
		RightTop,
		RightCenter,
		RightBottom,
	}

	[CRepr]
	public struct FloatingAttachPoints
	{
		public FloatingAttachPointType element;
		public FloatingAttachPointType parent;
	}

	public enum PointerCaptureMode : c_int
	{
		Capture,
		Passthrough,
	}

	public enum FloatingAttachToElement : c_int
	{
		None,
		Parent,
		ElementWithId,
		Root,
	}

	[CRepr]
	public struct FloatingElementConfig
	{
		public Vector2 offset;
		public Dimensions expand;
		public uint32 parentId;
		public int32 zIndex;
		public FloatingAttachPoints attachPoints;
		public PointerCaptureMode pointerCaptureMode;
		public FloatingAttachToElement attachTo;
	}

	[CRepr]
	public struct CustomElementConfig
	{
		public void* customData;
	}

	[CRepr]
	public struct ScrollElementConfig
	{
		public bool horizontal;
		public bool vertical;

		public this(bool horizontal, bool vertical)
		{
			this.horizontal = horizontal;
			this.vertical = vertical;
		}
	}

	[CRepr]
	public struct ClayBorder
	{
		public uint32 width = 0;
		public Color color = .();

		public this() { }

		public this(uint32 width = 0, Color color = .())
		{
			this.width = width;
			this.color = color;
		}
	}

	[CRepr]
	public struct BorderWidth
	{
		public uint16 left;
		public uint16 right;
		public uint16 top;
		public uint16 bottom;
		public uint16 betweenChildren;

		public this(uint16 left, uint16 right, uint16 top, uint16 bottom, uint16 between)
		{
			this.left = left;
			this.right = right;
			this.top = top;
			this.bottom = bottom;
			this.betweenChildren = between;
		}

		public this(uint16 all, uint16 between)
		{
			this.left = this.right = this.top = this.bottom = all;
			this.betweenChildren = between;
		}

		public this(uint16 all)
		{
			this.left = this.right = this.top = this.bottom = all;
			this.betweenChildren = 0;
		}
	}

	[CRepr]
	public struct BorderElementConfig
	{
		public Color color = .();
		public BorderWidth width = .(0);

		public this(uint16 width, Color color)
		{
			this.width = .(width);
			this.color = color;
		}

		public this()
		{
		}
	}

	[CRepr, Union]
	public struct ElementConfigUnion
	{
		public RectangleElementConfig* rectangleElementConfig;
		public TextElementConfig* textElementConfig;
		public ImageElementConfig* imageElementConfig;
		public FloatingElementConfig* floatingElementConfig;
		public CustomElementConfig* customElementConfig;
		public ScrollElementConfig* scrollElementConfig;
		public BorderElementConfig* borderElementConfig;
	}

	[CRepr]
	public struct ElementConfig
	{
		public ElementConfigType type;
		public ElementConfigUnion config;
	}

	[CRepr]
	public struct ScrollContainerData
	{
	   // Note: This is a pointer to the real internal scroll position, mutating it may cause a change in final layout.
	   // Intended for use with external functionality that modifies scroll position, such as scroll bars or auto scrolling.
		public Vector2* scrollPosition;
		public Dimensions scrollContainerDimensions;
		public Dimensions contentDimensions;
		public ScrollElementConfig config; // Indicates whether an actual scroll container matched the provided ID or if the default struct was returned.
		public bool found;
	}

	[CRepr]
	public struct ElementData
	{
		public BoundingBox boundingBox;
		// Indicates whether an actual Element matched the provided ID or if the default struct was returned.
		public bool found;
	}

	[CRepr]
	public struct TextRenderData
	{
		public StringSlice stringContents;
		public Color textColor;
		public uint16 fontId;
		public uint16 fontSize;
		public uint16 letterSpacing;
		public uint16 lineHeight;
	}

	[CRepr]
	public struct RectangleRenderData
	{
		public Color backgroundColor;
		public CornerRadius cornerRadius;
	}

	[CRepr]
	public struct ImageRenderData
	{
		public Color backgroundColor;
		public CornerRadius cornerRadius;
		public Dimensions sourceDimensions;
		public void* imageData;
	}

	[CRepr]
	public struct CustomRenderData
	{
		public Color backgroundColor;
		public CornerRadius cornerRadius;
		public void* customData;
	}

	[CRepr]
	public struct BorderRenderData
	{
		public Color color;
		public CornerRadius cornerRadius;
		public BorderWidth width;
	}

	[CRepr, Union]
	public struct RenderData
	{
		public RectangleRenderData rectangle;
		public TextRenderData text;
		public ImageRenderData image;
		public CustomRenderData custom;
		public BorderRenderData border;
	}

	public enum RenderCommandType : c_int
	{
		None,
		Rectangle,
		Border,
		Text,
		Image,
		ScissorStart,
		ScissorEnd,
		Custom,
	}

	[CRepr]
	public struct RenderCommand
	{
		public BoundingBox boundingBox;
		public RenderData renderData;
		public void* userData;
		public uint32 id;
		public int16 zIndex;
		public RenderCommandType commandType;
	}

	public enum PointerDataInteractionState : c_int
	{
		ClayPointerDataPressedThisFrame,
		ClayPointerDataPressed,
		ClayPointerDataReleasedThisFrame,
		ClayPointerDataReleased,
	}

	[CRepr]
	public struct PointerData
	{
		public Vector2 position;
		public PointerDataInteractionState state;
	}

	public enum ErrorType : c_int
	{
		TextMeasurementFunctionNotProvided,
		ArenaCapacityExceeded,
		ElementsCapacityExceeded,
		TextMeasurementCapacityExceeded,
		DuplicateId,
		FloatingContainerParentNotFound,
		InternalError,
	}

	[CRepr]
	public struct ErrorData
	{
		public ErrorType errorType;
		public String errorText;
		public void* userData;
	}

	public function void ErrorHandlerCallback(ErrorData errorData);

	[CRepr]
	public struct ErrorHandler
	{
		public ErrorHandlerCallback handler;
		public void* userData;

		public this(ErrorHandlerCallback handler, void* userData)
		{
			this.handler = handler;
			this.userData = userData;
		}
	}

	[CRepr]
	public struct ElementDeclaration
	{
		public ElementId id;
		public LayoutConfig layout;
		public Color backgroundColor;
		public CornerRadius cornerRadius;
		public ImageElementConfig image;
		public FloatingElementConfig floating;
		public CustomElementConfig custom;
		public ScrollElementConfig scroll;
		public BorderElementConfig border;
		public void* userData;
	}

	// public
	[CLink] public static extern uint32 Clay_MinMemorySize();
	[CLink] public static extern Arena Clay_CreateArenaWithCapacityAndMemory(uint32 capacity, uint8* offset);
	[CLink] public static extern void Clay_SetPointerState(Vector2 position, bool pointerDown);
	[CLink] public static extern void Clay_Initialize(Arena arena, Dimensions layoutDimensions, ErrorHandler errorHandler);
	[CLink] public static extern void Clay_UpdateScrollContainers(bool enableDragScrolling, Vector2 scrollDelta, float deltaTime);
	[CLink] public static extern void Clay_SetLayoutDimensions(Dimensions dimensions);
	[CLink] public static extern void Clay_BeginLayout();
	[CLink] public static extern Array<RenderCommand> Clay_EndLayout();
	[CLink] public static extern bool Clay_PointerOver(ElementId id);
	[CLink] public static extern ElementId Clay_GetElementId(String id);
	[CLink] public static extern ScrollContainerData Clay_GetScrollContainerData(ElementId id);
	[CLink] public static extern bool Clay_Hovered();
	[CLink] public static extern void Clay_SetMeasureTextFunction(function Dimensions(StringSlice text, TextElementConfig* config, void* userData) measureTextFunction, void* userData);
	[CLink] public static extern void Clay_OnHover(function void(ElementId elementId, PointerData pointerData, void* userData) onHoverFunction, void* userData);
	[CLink] public static extern RenderCommand* Clay_RenderCommandArray_Get(Array<RenderCommand>* array, int32 index);
	[CLink] public static extern void Clay_SetDebugModeEnabled(bool enabled);

	// internal
	[CLink] public static extern void Clay__OpenElement();
	[CLink] public static extern void Clay__ConfigureOpenElement(ElementDeclaration config);
	[CLink] public static extern void Clay__CloseElement();
	[CLink] public static extern void Clay__OpenTextElement(String text, TextElementConfig* textConfig);
	[CLink] public static extern TextElementConfig* Clay__StoreTextElementConfig(TextElementConfig);
	[CLink] public static extern ElementId Clay__HashString(String toHash, uint32 index, uint32 seed);
	[CLink] public static extern uint32 Clay__GetOpenLayoutElementId();

	public static ElementId Clay_GetElementId(System.String id)
	{
		return Clay_GetElementId(MakeClayString(id));
	}

	public struct ChildrenConfig
	{
		public function void() callback;
	}

	public struct DeclarationScope
	{
		public bool UI(ElementDeclaration config, delegate void() children = null)
		{
			defer
			{
				Clay__CloseElement();
			}
			Clay__ConfigureOpenElement(config);
			if (children != null)
			{
				children();
			}
			return true;
		}
	}

	public static DeclarationScope Elem
	{
		get
		{
			Clay__OpenElement();
			return default;
		}
	}

	public static bool UI(ElementDeclaration config, delegate void() children = null)
	{
		Clay__OpenElement();
		defer
		{
			Clay__CloseElement();
		}
		Clay__ConfigureOpenElement(config);
		if (children != null)
		{
			children();
		}
		return true;
	}

	public static SizingAxis FitMin(float min)
	{
		return SizingAxis(.Fit, SizingMinMax(min, 0));
	}

	public static SizingAxis FitMax(float max)
	{
		return SizingAxis(.Fit, SizingMinMax(0, max));
	}

	public static SizingAxis FitMinMax(float min, float max)
	{
		return SizingAxis(.Fit, SizingMinMax(min, max));
	}

	public static SizingAxis GrowMin(float min)
	{
		return SizingAxis(.Grow, SizingMinMax(min, 0));
	}

	public static SizingAxis GrowMax(float max)
	{
		return SizingAxis(.Grow, SizingMinMax(0, max));
	}

	public static SizingAxis Grow(float min, float max)
	{
		return SizingAxis(.Grow, SizingMinMax(min, max));
	}

	public static SizingAxis Fixed(float size)
	{
		return SizingAxis(.Fixed, SizingMinMax(size, size));
	}

	public static SizingAxis Percent(float sizePercent)
	{
		return SizingAxis(.Percent, sizePercent);
	}

	public static String MakeClayString(System.String label)
	{
		return .((.)label.Length, label);
	}
	
	[Comptime]
	public static ElementId ID(System.String label, uint32 index = 0)
	{
		return Clay__HashString(MakeClayString(label), index, 0);
	}

	public static ElementId ID(System.String label, uint32 index = 0)
	{
		return Clay__HashString(MakeClayString(label), index, 0);
	}

	public static void Text(System.String text, TextElementConfig config)
	{
		Clay__OpenTextElement(MakeClayString(text), Clay__StoreTextElementConfig(config));
	}
}
