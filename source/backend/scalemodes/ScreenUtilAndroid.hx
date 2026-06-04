package backend.scalemodes;



#if android
import backend.external.android.ScreenUtil as NativeScreenUtil;
#end
import lime.app.Application;
import lime.system.System;
import openfl.geom.Rectangle;

/**
 * A Utility class to get mobile screen related informations.
 */
class ScreenUtilAndroid
{
  /**
   * Get `Rectangle` Object that contains the dimensions of the screen's Notch.
   * Scales the dimensions to return coords in pixels, not points
   * @return Rectangle
   */
  public static function getNotchRect():Rectangle
  {
    final notchRect:Rectangle = new Rectangle();

    notchRect.x = 0.0;
    notchRect.y = 0.0;

    #if android
    final rectDimensions:Array<Array<Float>> = [[], [], [], []];

    // Push all the dimensions of the cutouts into an array
    for (rect in NativeScreenUtil.getCutoutDimensions())
    {
      rectDimensions[0].push(rect.x);
      rectDimensions[1].push(rect.y);
      rectDimensions[2].push(rect.width);
      rectDimensions[3].push(rect.height);
    }

    // Put all the dimensions into the rectangle
    for (i => dimensions in rectDimensions)
    {
      for (dimension in dimensions)
      {
        switch (i)
        {
          case 0:
            notchRect.x += dimension;
          case 1:
            notchRect.y += dimension;
          case 2:
            notchRect.width += dimension;
          case 3:
            notchRect.height += dimension;
        }
      }
    }
    
    #end

    return notchRect;
  }
}