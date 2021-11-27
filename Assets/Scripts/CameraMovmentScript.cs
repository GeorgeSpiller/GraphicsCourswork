using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMovmentScript : MonoBehaviour
{
    public float sensetivity = 100f;
    public float maxPlayerSpeed = 40f;
    public float actualPlayerSpeed = 0f;
    public bool camMovmentIsEnabled = true;


    private GameObject playerTorch;
    private float multiplier = 0.01f;
    private float mouseX;
    private float mouseY;
    private float xRot;
    private float yRot;

    private void Start()
    {
        playerTorch = transform.GetChild(0).gameObject;
        playerTorch.transform.localRotation = transform.rotation;
        // lock and hide the cursor for the first person camera
        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
    }

    private void Update()
    {
        // Check if the player has paused, if not manage first person camera movment
        if (camMovmentIsEnabled) 
        {
            // lock and hide cursor
            Cursor.visible = false;
            Cursor.lockState = CursorLockMode.Locked;
            // sets X and  rotations based on mouse movment
            HandelInput();
            // translate these rotations to the camera, X directly to local space, 
            // Y to transform rotation space
            transform.rotation = Quaternion.Euler(xRot, yRot, 0);
            //playerTorch.transform.localRotation = transform.rotation;
        }        
    }

    void HandelInput() 
    {
        // get mouse inputs
        mouseX = Input.GetAxisRaw("Mouse X");
        mouseY = Input.GetAxisRaw("Mouse Y");
        // scale rotation values based on sensitivity values and multiplers
        xRot -= mouseY * sensetivity * multiplier;
        yRot += mouseX * sensetivity * multiplier;
        
        bool isShiftKeyDown = Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift);

        if (isShiftKeyDown) 
        {
            actualPlayerSpeed = maxPlayerSpeed;
        } else {
            actualPlayerSpeed = maxPlayerSpeed / 2;
        }

        if (Input.GetKey ("w")) 
        {
            transform.position += transform.forward * Time.deltaTime * actualPlayerSpeed;
        }
        if (Input.GetKey ("a")) 
        {
            transform.position -= transform.right * Time.deltaTime * actualPlayerSpeed;
        }
        if (Input.GetKey ("s")) 
        {
            transform.position -= transform.forward * Time.deltaTime * actualPlayerSpeed;
        }
        if (Input.GetKey ("d")) 
        {
            transform.position += transform.right * Time.deltaTime * actualPlayerSpeed;
        }
        if (Input.GetMouseButton(0))
        {
            transform.position += transform.up * Time.deltaTime * actualPlayerSpeed;
        }
        if (Input.GetMouseButton(1)) 
        {
            transform.position -= transform.up * Time.deltaTime * actualPlayerSpeed;
        }
    } 
}
