class_name BrushFactory extends Object


#               010           110                         Z
#   Vertices     A0 ---------- B1            Faces      Top    -Y
#           011 /  |      111 /  |                        |   North
#             E4 ---------- F5   |                        | /
#             |    |        |    |          -X West ----- 0 ----- East X
#             |   D3 -------|-- C2                      / |
#             |  /  000     |  / 100               South  |
#             H7 ---------- G6                      Y    Bottom
#              001           101                          -Z


static func create_brush_at_points(map:MapDocumentBrush, id:int, p1:Vector3, p2:Vector3, material:StandardMaterial3D) -> Brush:
	var a := Vertex.new( Vector3(p1.x, p2.y, p1.z) )
	var b := Vertex.new( Vector3(p2.x, p2.y, p1.z) )
	var c := Vertex.new( Vector3(p2.x, p1.y, p1.z) )
	var d := Vertex.new( p1 )
	var e := Vertex.new( Vector3(p1.x, p2.y, p2.z) )
	var f := Vertex.new( p2 )
	var g := Vertex.new( Vector3(p2.x, p1.y, p2.z) )
	var h := Vertex.new( Vector3(p1.x, p1.y, p2.z) )

	var verts:Array[Vertex] = [a,b,c,d,e,f,g,h]

	var west   := Face.new([a,e,h,d], material)  # West
	var east   := Face.new([f,b,c,g], material)  # East
	var north  := Face.new([b,a,d,c], material)  # North
	var south  := Face.new([e,f,g,h], material)  # South
	var top    := Face.new([a,b,f,e], material)  # Top
	var bottom := Face.new([h,g,c,d], material)  # Bottom

	var ab := Edge.new(a,b) # AB
	var bf := Edge.new(b,f) # BF
	var fe := Edge.new(f,e) # FE
	var ea := Edge.new(e,a) # EA
	var dc := Edge.new(d,c) # DC
	var cg := Edge.new(c,g) # CG
	var gh := Edge.new(g,h) # GH
	var hd := Edge.new(h,d) # HD
	var ad := Edge.new(a,d) # AD
	var bc := Edge.new(b,c) # BC
	var fg := Edge.new(f,g) # FG
	var eh := Edge.new(e,h) # EH

	var edges:Array[Edge]= [ab,bf,fe,ea,dc,cg,gh,hd,ad,bc,fg,eh]
	var faces:Array[Face]= [west,east,north,south,top,bottom]

	west.edges   = [ea,hd,ad,eh]
	east.edges   = [bf,cg,bc,fg]
	north.edges  = [ab,dc,ad,bc]
	south.edges  = [fe,gh,fg,eh]
	top.edges    = [ab,bf,fe,ea]
	bottom.edges = [dc,cg,gh,hd]

	ab.faces = [north, top]
	bf.faces = [east, top]
	fe.faces = [south, top]
	ea.faces = [west, top]
	dc.faces = [north, bottom]
	cg.faces = [east, bottom]
	gh.faces = [south, bottom]
	hd.faces = [west, bottom]
	ad.faces = [west, north]
	bc.faces = [east, north]
	fg.faces = [east, south]
	eh.faces = [west, south]

	var brush := Brush.new(map, id, material, verts, faces, edges)
	return brush

