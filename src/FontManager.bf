namespace Clay;

using System;
using System.Collections;

using RaylibBeef;


public struct FontSpec : IHashable
{
	public uint FontId;
	public uint FontSize;
	public this(uint fontId, uint fontSize)
	{
		FontId = fontId;
		FontSize = fontSize;
	}
	public int GetHashCode()
	{
		return HashCode.Generate((FontId, FontSize));
	}
}

public class FontManager
{
    private static Dictionary<uint, StringView> mFontPaths = new .(1024) ~ delete _;
    private static String mPathBuffer = new .(1024 * 1024) ~ delete _;
    private static Dictionary<FontSpec, RaylibBeef.Font> mFonts = new .(1024) ~ delete _;

    public static void RegisterFont(uint fontId, StringView path, params uint[] preloadSizes)
    {
        Runtime.Assert(!mFontPaths.ContainsKey(fontId), "Register the font only once.");
        int startIndex = mPathBuffer.Length;
        String nullTerminatedPath = scope $"{path}\0";
        mPathBuffer.Append(nullTerminatedPath);
        mFontPaths[fontId] = mPathBuffer.Substring(startIndex);

		for(var eachSize in preloadSizes)
		{
			LoadFont(fontId, eachSize);
		}
    }

    public static RaylibBeef.Font LoadFont(uint fontId, uint fontSize)
    {
        Runtime.Assert(mFontPaths.ContainsKey(fontId));
        var spec = FontSpec(fontId, fontSize);
        if(!mFonts.ContainsKey(spec))
        {
            var path = mFontPaths[fontId];
            let font = Raylib.LoadFontEx(path.Ptr, (.)fontSize, null, 0);
            Raylib.SetTextureFilter(font.texture, RaylibBeef.TextureFilter.TEXTURE_FILTER_TRILINEAR);
            mFonts.Add(spec, font);
        }

        return mFonts[spec];
    }

    public static RaylibBeef.Font GetFont(uint fontId, uint fontSize)
    {
        FontSpec spec = .(fontId, fontSize);
        if(!mFonts.ContainsKey(spec))
        {
            LoadFont(fontId, fontSize);
        }

        return mFonts[spec];
    }
}