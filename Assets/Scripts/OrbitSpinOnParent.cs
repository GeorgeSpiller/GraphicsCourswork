using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OrbitSpinOnParent : MonoBehaviour
{

    public float speed = 50f;


    private Vector3 RotatePointAroundPivot(Vector3 point, Vector3 pivot, Quaternion angle) 
    {
        return angle * ( point - pivot) + pivot;
    }

    void Update()
    {
        // rotate around parent object
        transform.position = RotatePointAroundPivot(transform.position, 
        transform.parent.position, 
        Quaternion.Euler(0, speed * Time.deltaTime, 0) );
    }
}
