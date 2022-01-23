using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.InputSystem;

public class ControlChangeEntry : MonoBehaviour
{
    public SplineTest.GameMaster gm;
    InputActionAsset currentInputActions;
    public string associatedAction; //The action this entry is associated with
    public Text action1Text;
    public Text action2Text;
    public int bindIndex1;
    public int bindIndex2;
    InputAction action;

    void Awake()
    {
        currentInputActions = gm.currentActions;
        action = currentInputActions.FindAction(associatedAction);
        action1Text.text = action.GetBindingDisplayString(bindIndex1); //Safer just to use Unity's nomenclature
        action2Text.text = action.GetBindingDisplayString(bindIndex2);
        if (action1Text.text == "") action1Text.text = "None"; //Except if there isn't a control defined anyway
        if (action2Text.text == "") action2Text.text = "None";
    }

    public void RebindControl(int bindNum)
    {
        action.Disable(); //Prevent accidental triggering of the control while rebinding
        int bindInd = 0;
        if (bindNum == 0)
        {
            action1Text.text = "Waiting...";
            bindInd = bindIndex1;
        }
        else if (bindNum == 1)
        {
            action2Text.text = "Waiting...";
            bindInd = bindIndex2;
        }
        InputActionRebindingExtensions.RebindingOperation rebindAction = action.PerformInteractiveRebinding(bindInd).WithTimeout(10f).OnMatchWaitForAnother(0.1f);
        rebindAction.OnComplete(onCompleteAction => { //This is where the actual rebind takes place
            action1Text.text = action.GetBindingDisplayString(bindIndex1);
            action2Text.text = action.GetBindingDisplayString(bindIndex2);
            if (action1Text.text == "") action1Text.text = "None";
            if (action2Text.text == "") action2Text.text = "None";
            action.ChangeBinding(bindInd).WithPath(action.bindings[bindInd].effectivePath);
            action.Enable();
            onCompleteAction.Dispose();
        });
        rebindAction.Start(); //Restart action to prevent it being unusable
    }
}
