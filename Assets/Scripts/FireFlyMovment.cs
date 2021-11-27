using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireFlyMovment : MonoBehaviour
{
    public Transform cameraTransform;
    public float TargetRange = 50f;
    public float Speed = 10f; 

    private Vector3 targetLocation;
    private Vector3 tempCurrentPosition;

    bool isInRangeOfTarget() 
    {
        float targetDistance = Vector3.Distance(transform.position, targetLocation);
        
        return true ? targetDistance < 5f : false;
    }

    void newTarget() 
    {
        // offset by player position
        targetLocation = cameraTransform.position + (Random.insideUnitSphere * TargetRange);
    }

    void Start()
    {
        newTarget();
        transform.position = targetLocation;
        newTarget();
    }

    void Update()
    {
        if (Vector3.Distance(transform.position, cameraTransform.position) > TargetRange) 
        {
            newTarget();
            transform.position = targetLocation;
            newTarget();
            Speed = 40f;
        } else {
            Speed = 10f;
        }

        if (isInRangeOfTarget()) 
        {
            newTarget();            
            // TrailRenderer tr = GetComponent<TrailRenderer>();
            // // dissable trails during teleport 
            // tr.enabled = false;
            // transform.position = cameraTransform.position + (Random.onUnitSphere * despawnRange);
            // tr.enabled = true;
        } else {
            // move towards target
            tempCurrentPosition = Vector3.MoveTowards(transform.position, targetLocation, Speed * Time.deltaTime);
            transform.position = tempCurrentPosition;
            //transform.LookAt(targetLocation);
        }


        /*
        Taken from ur react project 
        light.current.position.x = originalPosX + Math.cos(clock.getElapsedTime()) * rad
        light.current.position.z = originalPosZ + Math.sin(clock.getElapsedTime()) * rad
        an orbit light
        */
    }
}
