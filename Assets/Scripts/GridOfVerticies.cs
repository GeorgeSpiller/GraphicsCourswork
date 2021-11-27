using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class GridOfVerticies : MonoBehaviour
{
    public int xSize, zSize = 20;
    public Material meshMaterial;
    private Vector3[] vertices;
    private Mesh mesh;
    
    private void Generate() 
    {
        // Since ajacent quads can share the same verts, we need (x+1) * (y+1) verts
        vertices = new Vector3[(xSize + 1) * (zSize + 1)];
        // Get our mesh and name it
        GetComponent<MeshFilter>().mesh = mesh = new Mesh();
		mesh.name = "MeshGrid";

        // spread the verts and calculate their attributes
		vertices = new Vector3[(xSize + 1) * (zSize + 1)];
        // need to calculate the uvs for applying textures to the mesh, and the tagents to correctly apply the bumpmap
        Vector2[] uv = new Vector2[vertices.Length];
        Vector4[] tangents = new Vector4[vertices.Length];
		Vector4 tangent = new Vector4(1f, 0f, 0f, -1f);
		for (int i = 0, z = 0; z <= zSize; z++) {
			for (int x = 0; x <= xSize; x++, i++) {
				vertices[i] = new Vector3(x, 0, z); // for random heights: Random.Range(0f, 3.0f)
                // force uv cords to be floats
                uv[i] = new Vector2((float)x / xSize, (float) z / zSize);
                tangents[i] = tangent;
			}
		}
        // asign verts, uv's and tangets to mesh
        mesh.vertices = vertices;
        mesh.uv = uv;
        mesh.tangents = tangents;

        // give the mesh some triangles
        int[] triangles = new int[xSize * zSize * 6];
        for (int quad = 0, k = 0, y = 0; y < zSize; y++, k++) {
			for (int x = 0; x < xSize; x++, quad += 6, k++) {
                triangles[quad] = k;
                triangles[quad + 3] = triangles[quad + 2] = k + 1;
                triangles[quad + 4] = triangles[quad+ 1] = k + xSize + 1;
                triangles[quad + 5] = k + xSize + 2;
            }
        }
		mesh.triangles = triangles;
        // set normals
        mesh.RecalculateNormals();
        // set material
        GetComponent<Renderer>().material = meshMaterial;
    }

    void Start() 
    {
        Generate();
    }

    void Update() 
    {
        // do genrate again, but scroll perlin noise?
        // seems a bit excessive for calculations in an update function
    }
}
