using System;
using System.Collections;
using System.Diagnostics;
using Clay;

using static RaylibBeef.Raylib;
using static Clay.Clay;

namespace example;

class RendererRaylib
{
	public static RaylibBeef.Color ClayToRaylibColor(Color color)
	{
		return .((uint8)Math.Floor(color.r), (uint8)Math.Floor(color.g), (uint8)Math.Floor(color.b), (uint8)Math.Floor(color.a));
	}

	public static Dimensions MeasureText(StringSlice text, TextElementConfig* config, void* userData)
	{
		float maxTextWidth = 0;
		float lineTextWidth = 0;
		float textHeight = config.size;
		RaylibBeef.Font fontToUse = FontManager.GetFont(config.font, config.size);

		float scaleFactor = config.size / fontToUse.baseSize;

		for (int i = 0; i < text.length; ++i)
		{
			if (text.chars[i] == '\n')
			{
				maxTextWidth = Math.Max(maxTextWidth, lineTextWidth);
				lineTextWidth = 0;
				continue;
			}

			int index = (.)text.chars[i] - 32;

			if (fontToUse.glyphs[index].advanceX != 0)
			{
				lineTextWidth += fontToUse.glyphs[index].advanceX;
			} else
			{
				lineTextWidth += (fontToUse.recs[index].width + fontToUse.glyphs[index].offsetX);
			}
		}

		maxTextWidth = Math.Max(maxTextWidth, lineTextWidth) * scaleFactor;

		return .(maxTextWidth, textHeight);
	}

	public static void Render(Clay.Clay.Array<Clay.Clay.RenderCommand>* renderCommands)
	{
		for (int32 i in (0 ..< renderCommands.length))
		{
			let renderCommand = Clay_RenderCommandArray_Get(renderCommands, i);

			let bb = renderCommand.boundingBox;

			switch (renderCommand.commandType)
			{
			case .ScissorStart:
				BeginScissorMode((.)bb.x, (.)bb.y, (.)bb.width, (.)bb.height);
			case .ScissorEnd:
				EndScissorMode();
			case .Rectangle:
				let config = renderCommand.renderData.rectangle;
				let color = ClayToRaylibColor(config.backgroundColor);
				if (config.cornerRadius.topLeft > 0)
				{
					let radius = (config.cornerRadius.topLeft * 2) / Math.Min(bb.width, bb.height);
					RaylibBeef.Raylib.DrawRectangleRounded(.(bb.x, bb.y, bb.width, bb.height), radius, 16, color);
				} else
				{
					RaylibBeef.Raylib.DrawRectangle((.)bb.x, (.)bb.y, (.)bb.width, (.)bb.height, color);
				}
			case .Text:
				let config = renderCommand.renderData.text;
				let font = FontManager.GetFont(config.fontId, config.fontSize);
				//let font = fonts.GetValue(config.fontId);
				let text = renderCommand.renderData.text.stringContents;

				char8* chars = scope char8[text.length + 1]*;
				for (int i < text.length)
				{
					chars[i] = text.chars[i];
				}

				chars[text.length + 1] = '\0';


				RaylibBeef.Raylib.DrawTextEx(
					font,
					chars,
					RaylibBeef.Vector2(Math.Round(bb.x), Math.Round(bb.y)),
					config.fontSize,
					0,
					ClayToRaylibColor(config.textColor)
					);

			case .Image:
				let config = renderCommand.renderData.image;

				RaylibBeef.Texture texture = *(RaylibBeef.Texture*)config.imageData;

				DrawTextureEx(
					texture,
					.(bb.x, bb.y),
					0,
					bb.width / texture.width,
					WHITE);

			case .Border:
				let config = renderCommand.renderData.border;

				// Left border
				if (config.width.left > 0)
				{
					RaylibBeef.Raylib.DrawRectangle(
						(int32)Math.Round(bb.x),
						(int32)Math.Round(bb.y + config.cornerRadius.topLeft),
						(int32)config.width.left,
						(int32)Math.Round(bb.height - config.cornerRadius.topLeft - config.cornerRadius.bottomLeft),
						ClayToRaylibColor(config.color)
						);
				}

				// Right border
				if (config.width.right > 0)
				{
					RaylibBeef.Raylib.DrawRectangle(
						(int32)Math.Round(bb.x + bb.width - config.width.right),
						(int32)Math.Round(bb.y + config.cornerRadius.topRight),
						(int32)config.width.right,
						(int32)Math.Round(bb.height - config.cornerRadius.topRight - config.cornerRadius.bottomRight),
						ClayToRaylibColor(config.color)
						);
				}

				// Top border
				if (config.width.top > 0)
				{
					RaylibBeef.Raylib.DrawRectangle(
						(int32)Math.Round(bb.x + config.cornerRadius.topLeft),
						(int32)Math.Round(bb.y),
						(int32)Math.Round(bb.width - config.cornerRadius.topLeft - config.cornerRadius.topRight),
						(int32)config.width.top,
						ClayToRaylibColor(config.color)
						);
				}

				// Bottom border
				if (config.width.bottom > 0)
				{
					RaylibBeef.Raylib.DrawRectangle(
						(int32)Math.Round(bb.x + config.cornerRadius.bottomLeft),
						(int32)Math.Round(bb.y + bb.height - config.width.bottom),
						(int32)Math.Round(bb.width - config.cornerRadius.bottomLeft - config.cornerRadius.bottomRight),
						(int32)config.width.bottom,
						ClayToRaylibColor(config.color)
						);
				}

				if (config.cornerRadius.topLeft > 0)
				{
					RaylibBeef.Raylib.DrawRing(
						.(Math.Round(bb.x + config.cornerRadius.topLeft), Math.Round(bb.y + config.cornerRadius.topLeft)),
						Math.Round(config.cornerRadius.topLeft -  config.width.top),
						config.cornerRadius.topLeft,
						180,
						270,
						10,
						ClayToRaylibColor(config.color)
						);
				}

				if (config.cornerRadius.topRight > 0)
				{
					RaylibBeef.Raylib.DrawRing(
						.(Math.Round(bb.x + bb.width - config.cornerRadius.topRight), Math.Round(bb.y + config.cornerRadius.topRight)),
						Math.Round(config.cornerRadius.topRight -  config.width.top),
						config.cornerRadius.topRight,
						270,
						360,
						10,
						ClayToRaylibColor(config.color)
						);
				}

				if (config.cornerRadius.bottomLeft > 0)
				{
					RaylibBeef.Raylib.DrawRing(
						.(Math.Round(bb.x + config.cornerRadius.bottomLeft), Math.Round(bb.y + bb.height - config.cornerRadius.bottomLeft)),
						Math.Round(config.cornerRadius.bottomLeft -  config.width.top),
						config.cornerRadius.bottomLeft,
						90,
						180,
						10,
						ClayToRaylibColor(config.color)
						);
				}

				if (config.cornerRadius.bottomRight > 0)
				{
					RaylibBeef.Raylib.DrawRing(
						.(Math.Round(bb.x + bb.width - config.cornerRadius.bottomRight), Math.Round(bb.y + bb.height - config.cornerRadius.bottomRight)),
						Math.Round(config.cornerRadius.bottomRight - config.width.bottom),
						config.cornerRadius.bottomRight,
						0.1f,
						90,
						10,
						ClayToRaylibColor(config.color)
						);
				}
				break;
			default:
			}
		}
	}
}