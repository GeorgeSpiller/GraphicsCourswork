using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour
{

    public float targetMetThreshold = 10f;
    private Quaternion targetRotation;


    // Start is called before the first frame update
    void Start()
    {
        targetRotation = Random.rotation;
    }

    // Update is called once per frame
    void Update()
    {
        float difference = Quaternion.Angle(transform.rotation, targetRotation);
        if (difference <= targetMetThreshold) 
        {
            targetRotation = Random.rotation;
        } else {
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, 0.5f * Time.deltaTime);
        }
    }
}
