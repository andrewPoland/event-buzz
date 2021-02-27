using System;
using System.Diagnostics.CodeAnalysis;

namespace ToyCollection
{
    public abstract class Toy 
    { 
        [DisallowNull]
        public string Barcode { get; set;} = Guid.NewGuid().ToString();

        [DisallowNull]
        public string Name {get; set;} = Guid.NewGuid().ToString();

        public virtual Condition Condition { get; set;}
    }
}
