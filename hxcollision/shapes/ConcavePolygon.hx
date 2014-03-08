package hxcollision.shapes;

import hxcollision.math.Triangulator;
import hxcollision.math.Vector2D;
import hxcollision.shapes.Shape;

class ConcavePolygon extends Shape
{
    public var polygons(default,null):Array<Polygon>;

    public function new( x:Float, y:Float, polygons:Array<Polygon> ) {

        super( x,y );

        name = vertices.length + 'polygon';

        this.polygons = polygons;
    }

    public static function createFromVertices(vertices:Array<Vector2D>):ConcavePolygon
    {
        return new ConcavePolygon(0,0,Triangulator.triangulatePolygon(vertices));
    }

    override public function destroy() : Void {

        var _count : Int = _vertices.length;
        for(i in 0 ... _count) {
            _vertices[i] = null;
        }

        _vertices = null;
        super.destroy();
    }

    public function transformChildren():Void
    {
        if (!_transformed){
            _transformed = true;
            for (poly in polygons){
                poly.scaleX = scaleX;
                poly.scaleY = scaleY;
                poly.x = x;
                poly.y = y;
                poly.rotation = rotation;
            }
        }
    }

}
