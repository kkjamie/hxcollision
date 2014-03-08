package hxcollision.math;

import hxcollision.shapes.Polygon;

/*
 * Ported to haxe from http://www.ewjordan.com/earClip/
 *
 */

class Triangulator
{
    /*
     * Triangulates a polygon using simple O(N^2) ear-clipping algorithm
     * Returns a Triangle array unless the polygon can't be triangulated,
     * in which case null is returned.  This should only happen if the
     * polygon self-Intersects, though it will not _always_ return null
     * for a bad polygon - it is the caller's responsibility to check for
     * self-Intersection, and if it doesn't, it should at least check
     * that the return value is non-null before using.  You're warned!
     */

    public static function triangulatePolygon(vertices:Array<Vector2D>):Array<Polygon>
    {
        var buffer:Array<Polygon>  = new Array<Polygon>();
        var bufferSize:Int = 0;
        var vrem:Array<Vector2D>  = new Array<Vector2D>();
        vrem = vertices.copy();

        var vNum = vertices.length;

        while (vNum > 3){
            //Find an ear
            var earIndex:Int = -1;
            for (i in 0...vNum)
            {
                if (isEar(i,vrem)) {
                    earIndex = i;
                    break;
                }
            }
    
            //If we still haven't found an ear, we're screwed.
            //The user did Something Bad, so return null.
            //This will probably crash their program, since
            //they won't bother to check the return value.
            //At this we shall laugh, heartily and with great gusto.
            if (earIndex == -1) return null;

            //Clip off the ear:
            //  - remove the ear tip from the list

            //Opt note: actually creates a new list, maybe
            //this should be done in-place instead.  A linked
            //list would be even better to avoid array-fu.
            vNum--;
            var newVerts:Array<Vector2D> = new Array<Vector2D>();

            var currDest:Int  = 0;
            for (i in 0...vNum)
            {
                if (currDest == earIndex) ++currDest;
                {
                    newVerts[i] = vrem[currDest];
                    currDest++;
                }
            }

            //  - add the clipped triangle to the triangle list
            var under:Int = (earIndex==0) ? (vrem.length-1):(earIndex-1);
            var over:Int = (earIndex==vrem.length-1)?0:(earIndex+1);

            var toAdd:Polygon = new Polygon(0,0, [vrem[earIndex],vrem[over],vrem[under]]);
            buffer[bufferSize] = toAdd;
            bufferSize++;
//
//            trace("adding poly");
//            trace([vrem[earIndex],vrem[over],vrem[under]]);

            //  - replace the old list with the new one
            vrem = newVerts;
        }

        var toAdd:Polygon = new Polygon(0,0,[vrem[1],vrem[2],vrem[0]]);
        buffer[bufferSize] = toAdd;
        bufferSize++;
//
//        trace("adding poly");
//        trace([vrem[1],vrem[2],vrem[0]]);

        var res:Array<Polygon> = new Array<Polygon>();
        return buffer.copy();
    }

    //Checks if vertex i is the tip of an ear
    private static function isEar(i:Int, verts:Array<Vector2D>):Bool
    {
        var dx0:Float, dy0:Float, dx1:Float, dy1:Float;
        dx0=dy0=dx1=dy1=0;
        if (i >= verts.length || i < 0 || verts.length < 3){
            return false;
        }
        var upper:Int = i+1;
        var lower:Int = i-1;
        if (i == 0){
            dx0 = verts[0].x - verts[verts.length-1].x;
            dy0 = verts[0].y - verts[verts.length-1].y;
            dx1 = verts[1].x - verts[0].x;
            dy1 = verts[1].y - verts[0].y;
            lower = verts.length-1;
        } else if (i == verts.length-1){
            dx0 = verts[i].x - verts[i-1].x;
            dy0 = verts[i].y - verts[i-1].y;
            dx1 = verts[0].x - verts[i].x;
            dy1 = verts[0].y - verts[i].y;
            upper = 0;
        } else{
            dx0 = verts[i].x - verts[i-1].x;
            dy0 = verts[i].y - verts[i-1].y;
            dx1 = verts[i+1].x - verts[i].x;
            dy1 = verts[i+1].y - verts[i].y;
        }
        var cross:Float = dx0*dy1-dx1*dy0;
        if (cross < 0) return false;
        var myTri:Polygon = new Polygon(0,0, [verts[i],verts[upper],verts[lower]]);
        for (j in 0...verts.length){
            if (j==i || j == lower || j == upper) continue;
            if (isInside(myTri,verts[j])) return false;
        }
        return true;
    }

    private static function isInside(poly:Polygon, _vec:Vector2D):Bool{
        
        var vx2:Float = _vec.x-poly.vertices[0].x;
        var vy2:Float = _vec.y-poly.vertices[0].y;
        var vx1:Float = poly.vertices[1].x-poly.vertices[0].x;
        var vy1:Float = poly.vertices[1].y-poly.vertices[0].y;
        var vx0:Float = poly.vertices[2].x-poly.vertices[0].x;
        var vy0:Float = poly.vertices[2].y-poly.vertices[0].y;
        
        var dot00:Float = vx0*vx0+vy0*vy0;
        var dot01:Float = vx0*vx1+vy0*vy1;
        var dot02:Float = vx0*vx2+vy0*vy2;
        var dot11:Float = vx1*vx1+vy1*vy1;
        var dot12:Float = vx1*vx2+vy1*vy2;
        var invDenom:Float = 1.0 / (dot00*dot11 - dot01*dot01);
        var u:Float = (dot11*dot02 - dot01*dot12)*invDenom;
        var v:Float = (dot00*dot12 - dot01*dot02)*invDenom;
        
        return ((u>0)&&(v>0)&&(u+v<1));
    }

    /*
     * The following method has not been converted to haxe, assumed that it converts triangles back to polygons, it could be useful some day
     */

    //    private function polygonizeTriangles(triangulated:Array<Polygon>):Array<Polygon>
    //    {
    //        Polygon[] polys;
    //        Int polyIndex = 0;
    //
    //        if (triangulated == null){
    //        return null;
    //        } else{
    //        polys = new Polygon[triangulated.length];
    //        Bool[] covered = new Bool[triangulated.length];
    //        for (Int i=0; i<triangulated.length; i++){
    //        covered[i] = false;
    //        }
    //
    //        Bool notDone = true;
    //
    //        while(notDone){
    //        Int currTri = -1;
    //        for (Int i=0; i<triangulated.length; i++){
    //        if (covered[i]) continue;
    //        currTri = i;
    //        break;
    //        }
    //        if (currTri == -1){
    //        notDone = false;
    //        } else{
    //        Polygon poly = new Polygon(triangulated[currTri]);
    //        covered[currTri] = true;
    //        for (Int i=0; i<triangulated.length; i++){
    //        if (covered[i]) continue;
    //        Polygon newP = poly.add(triangulated[i]);
    //        if (newP == null) continue;
    //        if (newP.isConvex()){
    //        poly = newP;
    //        covered[i] = true;
    //        }
    //        }
    //        polys[polyIndex] = poly;
    //        polyIndex++;
    //        }
    //        }
    //        }
    //        Polygon[] ret = new Polygon[polyIndex];
    //        for (Int i=0; i<polyIndex; i++){
    //        ret[i] = polys[i];
    //        }
    //        return ret;
    //    }
}